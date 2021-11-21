const dasha = require("@dasha.ai/sdk");
//const express = require('express');
const axios = require('axios');

async function main() {
	while (true) {
		// Pick a phone number
		var number = pickRandomNumber(["+1226", "+1519"]);

		console.log("Calling " + number);

		// Call it!
		var responses = await call(number);
		console.log("Call complete!");

		// Get the response back and send it to API
		if (!responses || responses.length < 3) {
			// Call failed somehow
			console.log("The call didn't work. Trying another number!");
			continue;
		} else {
			// We got responses!
			console.log("Sending data " + responses);
			await sendData(await parseResponses(responses));
		}
	}
}
async function parseResponses(responses) {
	var newResponses = []

	// Handle response A
	switch (responses[0]) {
		case "A":
			newResponses.push("0.25");
			break;
		case "B":
			newResponses.push("1");
			break;
		case "C":
			newResponses.push("0");
			break;
		case "D":
			newResponses.push("0.75");
			break;
	}

	// Concatenate responses B,C
	newResponses.push(responses[1] + responses[2]);

	// Add response D
	newResponses.push(responses[3]);

	console.log(newResponses)
	return newResponses;
}

async function sendData(responses) {
	const data = {
		value1: responses[0],
		value2: responses[1],
		value3: responses[2]
	}

	console.log("here's the JSON", data);
	const sendInfo = async () => {
		try {
			await axios.post("https://maker.ifttt.com/trigger/wai_call_push/with/key/dXBKH2sg9SNM_9KZIb-tzF", data);
			console.log(data);
		} catch (err) {
			console.error(err);
		}
	};

	sendInfo();

}

function pickRandomNumber(areacodes) {
	var areacode = areacodes[Math.floor(Math.random() * areacodes.length)];
	return areacode + Math.floor(Math.random() * 10000000);
}

async function call(number) {
	const responses = [];

	// Declare app
	const app = await dasha.deploy("./app");

	app.connectionProvider = async (conv) =>
		conv.input.phone === "chat"
			? dasha.chat.connect(await dasha.chat.createConsoleChat())
			: dasha.sip.connect(new dasha.sip.Endpoint("default"));

	app.ttsDispatcher = () => "dasha";

	// Add functions
	var consent = false, hungup = false;
	app.setExternal("callHungUp", (args, conv) => {
		hungup = true;
		return;
	});
	app.setExternal("confirmFour", (args, conv) => {
		console.log("The data recorded is ", args.answer);
		if (args.answer === 'A') {
			responses.push(args.answer);
			return;
		} else if (args.answer === 'B') {
			responses.push(args.answer);
			return;
		} else if (args.answer === 'C') {
			responses.push(args.answer);
			return;
		} else if (args.answer === 'D') {
			responses.push(args.answer);
			return;
		}
	});
	app.setExternal("confirmTwo", (args, conv) => {
		console.log("The data recorded is ", args.answer);
		if (args.answer === 'A') {
			responses.push(args.answer);
			return;
		} else if (args.answer === 'B') {
			responses.push(args.answer);
			return;
		}
	});

	await app.start();
	const conv = app.createConversation({ phone: number }); // TODO: replace with random phone numbers
	if (conv.input.phone !== "chat") conv.on("transcription", console.log);
	await dasha.chat.createConsoleChat(conv);
	const result = await conv.execute();


	console.log("Result...", result.output);

	await app.stop();
	app.dispose();

	console.log("processed data", responses);

	if (hungup) {
		return false;
	}
	return responses;


}
main().catch(() => { });