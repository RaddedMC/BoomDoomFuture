import "commonReactions/all.dsl";

context
{
    // input phone number
    input phone: string;

    // Data collected
    question1number: number = 0;
    question2answer: boolean = false; // false = B, true = A
    question3answer: boolean = false; // false = B, true = A
    question4answer: string = ""; // A, B, C, D

    // Consent
    consent: boolean = false;
}

external function consentTrue():empty;
external function callHungUp():empty;
external function appendResponse(answer: string):empty;
external function compareStrings(answer1:string, asnwer2:string):boolean;
external function confirmOne(answer:string):empty;
external function confirmTwo(answer:string):empty;
external function confirmThree(answer:string):empty;
external function confirmFour(answer:string):empty;

start node root
{
    do
    {
        #connectSafe($phone);
        #waitForSpeech(1000);

        // Greet the caller
        #sayText("Hi there! I'm a representative from Western University's A Eye club. I was hoping if I could ask you a few questions about your opinion of artificial intelligence for a study which will take less than 5 minutes");
        wait *;
    }

    // Do they want to do the survey?
    transitions 
    {
        yes: goto survey_yes on #messageHasIntent("yes");
        no: goto survey_no on #messageHasIntent("no");
        //repeat: goto 
    }
}

// They don't want to do the survey
node survey_no
{
    do 
    {
        #sayText("No worries, Have a great day.");
        exit;
    }
}

// They do!
node survey_yes 
{
    do 
    {
        #sayText("Awesome! I knew you were a computer geek. Let's get started with the survey.");

        #sayText("Before we start, I'd like to ask if you are okay with your responses being recorded?");
        wait *;
    }

    // Do they consent to being recorded?
    transitions
    {
        yes: goto consent_yes on #messageHasIntent("yes");
        no: goto survey_no on #messageHasIntent("no");
    }
}

// They consent to being recorded
node consent_yes
{
    do
    {
        #sayText("Great! Thank you very much. Let's start the survey!");
        goto any;
    }

    transitions {
        any: goto q1;
    }
}

node q1 {
    do
    {
        #sayText("Here's the first question. You’re a factory employee whose job was entirely wiped out and replaced with robots. You have no way of completing this same job at a different facility or country as the entire industry has phased out your career path. What direction do you take your life? Do you, A, Attempt to find a minimum-wage job to support yourself? B, Take on a loan that could be extremely financially dangerous to get a college or university degree? C, Give up on your career and survive from government assistance? D, Teach yourself some new skill that could potentially be employable but would be a lot of work to learn?");
        wait*;
    }
    transitions {
        selector: goto questionOneSelector on #messageHasData("option");
    }
}

node q2 {
    do
    {
        #sayText("Here's the second question. This is a trolley problem. It will require you to make an ethical decision that has no truly correct answer. You’re driving a car when a baby suddenly walks in front of your vehicle, giving you no time to react. This is a multiple choice question, and there are no other options except for the ones listed. Will you, A. Swerve away and crash into some kind of wall, which is guaranteed to kill either you or one of your passengers? or B. Keep driving and plough through the baby, which is guaranteed to kill it.");
        wait *;
    }
    transitions {
        selector: goto questionTwoSelector on #messageHasData("option");
    }
}

node q3 {
    do
    {
        #sayText("Here's the next question: If, in a few short years, AI technology were to develop to the point that it had similar intelligence levels to humans, do you believe that they should be given rights? Your choices are. A. Yes, they should be given full rights just like you and me, they're sentient after all. B. No, they should be expected to perform their designed task to their fullest and be given no other freedoms, they're robots after all.");
        wait *;
    }
    transitions {
        selector: goto questionThreeSelector on #messageHasData("option");
    }
}

node q4 {
    do
    {
        #sayText("The final next question is: How would you feel if you discovered that the real world you live in today is actually a computer simulation? Would you, A. Submit yourself to your robot overlords, B. Take the red pill and suffer a potentially unsettling or life-changing truth C. Give up on everything, D. Live your life totally normally like nothing ever happened?");
        wait *;
    }
    transitions {
        selector: goto questionFourSelector on #messageHasData("option");
    }
}

node bye {
    do 
    {
        #sayText("Thank you for taking our survey! We feel that now is the best time to notify you, that I am actually not a person, but an AI named Dasha. Your contribution is appreciated and will be of great help for our team’s submission to Hack Western! Thanks again, and have a great day.");
        exit;
    }
}

node questionOneSelector {
    do {
        external confirmFour(#messageGetData("option", { value: true })[0]?.value??"");
        goto q2;
    }
    transitions {
        q2: goto q2;
    }
}

node questionTwoSelector {
    do {
        external confirmTwo(#messageGetData("option", { value: true })[0]?.value??"");
        goto q3;
    }
    transitions {
        q3: goto q3;
    }
}

node questionThreeSelector {
    do {
        external confirmTwo(#messageGetData("option", { value: true })[0]?.value??"");
        goto q4;
    }
    transitions {
        q4: goto q4;
    }
}

node questionFourSelector {
    do {
        external confirmFour(#messageGetData("option", { value: true })[0]?.value??"");
        goto bye;
    }
    transitions {
        bye: goto bye;
    }
}

digression repeat
{
    conditions { on #messageHasIntent("repeat"); }
    do {
        #repeat();
        return;
    }
}