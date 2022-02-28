Map<String, Map<String, String>> _dialogTexts = {
  'en': {
    'hello1': "Welcome and thanks for joining our study!",
    'hello2': "Thanks for answering my questions. This is a prototype of an occupational health interface that enables you to read various tips about healthy behaviors, and track your own progress.",
    'hello3': "My aim with this study is to evaluate the usability of this interface, in other words, to see how easy it is to use this application.",
    'hello4': "So, I will ask you to perform various tasks with the interface. You will have to navigate through different windows.",
    'hello5': "You will need to come back to this chat each time after you have succesfully accomplished a task. I will then give you your next task.",
    'hello6': "This study should take between 10 to 15 minutes. You will see the submission link once you complete all the tasks. Make sure that there is nothing that interrupts you.",
    'hello7': "Great! So, let's start with your first task if you are ready.",

    'taskUnreadTips': "It seems like you have some healthy living tips that you have not yet read. Could you read one of them?",
    'taskInfovis': "Now I want you to have a look at your physical activity data.",
    'taskDiaryEntry': "Excellent, it seems like you are also keeping a 'Stress Diary', please make an entry to it.",
    'taskSchedule': "I now want you to enter your work schedule information.",

    'age': "I would first like to learn more about you. What is your age?",
    'gender': "What is your gender?",
    'vision': "At the present time, would you say your eyesight using both eyes (with glasses or contact lenses, if you wear them) is:",
    'manual': "How easy or how hard is it for you to type or tap on mobile devices?",
    'appUse': "Which of the following apps do you use at least once every day?",
    'None of them': 'None of them',

    'likertDiff': "Would you agree that this was an easy task? (1: Completely disagree, 6: Completely agree)",
    'openEnded': "Please write what you found hard (if any) or if you can think of any improvements.",
    'uploadRequest': "That was all my questions. Please hit the button below to upload your session data.",
    'complete1': "Thanks again for your participation! Please follow this link to confirm your submission: https://app.prolific.co/submissions/complete?cc=7CB970C7",
    'complete2': "Well, since you asked. We are also looking for participants for longitudinal evaluations. If you are interested in helping us develop this occupational health application, leave your contact information to this link. This will not be in anyway associated with the information you entered in this study.",

    'finalQ': "Congratulations, You have completed all the tasks. Now, I will present you some statements about the app. Please rate them within the scale of 1 to 6 (1:Completely disagree and 6: Completely agree).",
    'finalQ1': "It was easy to learn how to use this app.",
    'finalQ2': "I think this app was easy to use.",
    'finalQ3': "Overall, I am satisfied of how I used this app.",
    'finalQ4': "I would like to use this app again.",
    'finalQ5': "I would recommend this app to a friend.",
    'finalQ6': "The buttons were so close that I accidentally selected the wrong button.",
    'finalQ7': "The text is clear to read.",
    'finalQ8': "The app looks tidy.",
    'finalQ9': "The terms used in the app were easily understandable.",
    'finalQ10': "The icons used in the app were easily understandable.",
    'finalQOpen': "Do you have any general comments/ideas that you would like to add?",

  },
  'fi': {

  },
};


String getDText (code){
  return _dialogTexts['en'][code];
}
