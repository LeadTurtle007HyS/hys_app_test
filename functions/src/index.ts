  
import * as functions from 'firebase-functions'
import * as express from 'express'
import { addEntry, getAllEntries, updateEntry, deleteEntry } from './entryController'
import { admin } from './config/firebase'

const fcm = admin.messaging();


const app = express()
app.get('/', (req, res) => res.status(200).send('Hey there!'))

app.post('/entries', addEntry)
app.get('/entries', getAllEntries)
app.patch('/entries/:entryId', updateEntry)
app.delete('/entries/:entryId', deleteEntry)

exports.app = functions.https.onRequest(app)


export const notifySuperUser_QuestionPosted = functions.firestore
    .document('questionaddedrequestsent/{ID}')
    .onCreate(async snapshot => {
        const message = snapshot.data();
        const token = message.token;
        

        const payload: admin.messaging.MessagingPayload = {
           notification:{
          title: `HyS | ${message.sendername} having a doubt.`,
          body:message.message,
          clickAction:'FLUTTER_NOTIFICATION_CLICK',
          sound:"default"
      },
      data:{
        sendername:message.sendername,
        senderid:message.senderid,
        receivername:message.receivername,
        receiverid:message.receiverid,
        message:message.message,
        notificationid:message.notificationid,
        questionid:message.questionid
      }
        }
        return fcm.sendToDevice(token, payload);

    });


    

    
export const notifyRequester_superuserResponse = functions.firestore
.document('superuserresponseonquestionadded/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `HyS | ${message.sendername} is ready to help you.`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
          sendername:message.sendername,
          senderid:message.senderid,
          receivername:message.receivername,
          receiverid:message.receiverid,
          message:message.message,
          notificationid:message.notificationid,
          questionid:message.questionid,
          response:message.response
        }
    }
    return fcm.sendToDevice(token, payload);

});


    
export const notifyCallingRequester_toSuperuser = functions.firestore
.document('callingresponsetosuperuserquestionadded/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        // notification:{
        //     title: `HyS | ${message.sendername} Calling...`,
        //     body:message.message,
        //     clickAction:'FLUTTER_NOTIFICATION_CLICK',
        //     sound:"default"
        // },
        data:{
          sendername:message.sendername,
          senderid:message.senderid,
          receivername:message.receivername,
          receiverid:message.receiverid,
          answerpreference:message.answerpreference,
          message:message.message,
          notificationid:message.notificationid,
          questionid:message.questionid,
          channelid:message.channelid
        },
    }
    const option: admin.messaging.MessagingOptions = {
        android:{
            ttl:4500
        }
    };
    return fcm.sendToDevice(token, payload,option);

});


    
export const questionAskReference = functions.firestore
.document('questionaskreference/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.receivertokenid;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `${message.referencername}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
            referencername:message.referencername,
          questionid:message.questionid,
          referencerid:message.referencerid,
          notificationid: "askareference"
        }
    }
    return fcm.sendToDevice(token, payload);

});


export const answerAskReference = functions.firestore
.document('answeraskreference/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.receivertokenid;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `${message.referencername}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
            referencername:message.referencername,
          questionid:message.questionid,
          referencerid:message.referencerid,
          notificationid: "askareference"
        }
    }
    return fcm.sendToDevice(token, payload);

});
 
export const notifications = functions.firestore.document('answernotification/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `${message.tittle}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
            answerid: message.answerid,
            answererid: message.answererid,
            answerername: message.answerername,
            token: message.token,
            message: message.message,
            tittle: message.tittle,
            userid: message.userid,
            username: message.username,
            createdate: message.createdate,
            function:message.function,
            notificationtype: "answernotification",
            comparedate: message.comparedate
        }
    }
    return fcm.sendToDevice(token, payload);

});

//like,imp,helpful
export const answerNotifications = functions.firestore
.document('answernotification/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `${message.tittle}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        
        data:{
            answerid: message.answerid,
            answererid: message.answererid,
            answerername: message.answerername,
            token: message.token,
            message: message.message,
            tittle: message.tittle,
            userid: message.userid,
            username: message.username,
            createdate: message.createdate,
            function:message.function,
            notificationtype: "answernotification",
            comparedate: message.comparedate
        }
    }
    return fcm.sendToDevice(token, payload);

});



export const notificationforbucketB = functions.firestore
.document('notificationforbucketB/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `HyS`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
            senderid: message.senderid,
            sendername:message.sendername,
            receiverid: message.receiverid,
            receivername: message.receivername,
            token: message.token,
            message: message.message,
            questionid: message.questionid,
            tokenvalue: message.token,
            notificationid: message.notificationid,
            createdate: message.createdate,
            notificationtype: message.notificationtype,
            comparedate: message.comparedate
        }
    }
    return fcm.sendToDevice(token, payload);

});




export const timeTableNotification = functions.firestore
.document('timetablenotifications/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `HyS`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
      notificationid: message.notificationid,
      senderid: message.senderid,
      senderprofile: message.senderprofile,
      sendername: message.sendername,
      receivername: message.receivername,
      receiverid: message.receiverid,
      starttime: message.starttime,
      endtime: message.endtime,
      frequency: message.frequency,
      subject: message.subject,
      topic: message.topic
            
        }
    }
    return fcm.sendToDevice(token, payload);

});




//like,imp,helpful
export const questionNotifications = functions.firestore
.document('questionnotification/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `${message.tittle}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
            questionid: message.questionid,
            questionerid: message.questionerid,
            questionername: message.questionername,
            token: message.token,
            message: message.message,
            tittle: message.tittle,
            userid: message.userid,
            username: message.username,
            createdate: message.createdate,
            function:message.function,
            notificationtype: "questionnotification",
            comparedate: message.comparedate
        }
    }
    return fcm.sendToDevice(token, payload);

});



//like,imp,helpful
export const allnotifications = functions.firestore
.document('allnotifications/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `${message.tittle}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
            questionid: message.questionid,
            questionerid: message.receiverid,
            questionername: message.receivername,
            token: message.token,
            message: message.message,
            tittle: message.tittle,
            userid: message.senderid,
            username: message.sendername,
            notificationtype: message.notificationid
        }
    }
    return fcm.sendToDevice(token, payload);

});

export const allChatnotifications = functions.firestore
.document('allchatnotifications/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `${message.tittle}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
            chatuserdetailszero: message.chatuserdetailszero,
            chatuserdetailsone: message.chatuserdetailsone,
            chatuserdetailstwo: message.chatuserdetailstwo,
            chatuserdetailsthree: message.chatuserdetailsthree,
            chatuserdetailsfour: message.chatuserdetailsfour,
            chatuserdetailsfive: message.chatuserdetailsfive,
            chatid: message.chatid,
            receiverid: message.receiverid,
            receivername: message.receivername,
            token: message.token,
            message: message.message,
            tittle: message.tittle,
            senderid: message.senderid,
            sendername: message.sendername,
            notificationtype: message.notificationid
        }
    }
    return fcm.sendToDevice(token, payload);

});



export const joineventnotifications = functions.firestore
.document('eventnotifications/{ID}')
.onCreate(async snapshot => {
    const message = snapshot.data();
    const token = message.token;
    

    const payload: admin.messaging.MessagingPayload = {
        notification:{
            title: `${message.tittle}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },
        data:{
            eventname: message.eventname,
            meetingid: message.meetingid,
            date: message.date,
            fromtime: message.fromtime,
            totime: message.totime,
            username: message.username,
            userid: message.userid,
            tittle: message.tittle,
            message: message.message,
            token: message.token,
            notificationid: message.notificationid
        }
    }
    return fcm.sendToDevice(token, payload);

});

//like,imp,helpful

export const newNotifications = functions.firestore

.document('new_notification/{ID}')

.onCreate(async snapshot => {

    const message = snapshot.data();

    const token = message.token;

    const payload: admin.messaging.MessagingPayload = {

        notification:{
            title: `${message.tittle}`,
            body:message.message,
            clickAction:'FLUTTER_NOTIFICATION_CLICK',
            sound:"default"
        },

        data:{

            post_id: message.post_id,

            notify_section: message.notify_section,

            notify_function: message.notify_function,

            token: message.token,

            message: message.message,

            tittle: message.tittle,

            sender_id: message.sender_id,

            receiver_id: message.receiver_id,

            comparedate: message.comparedate

        }

    }

    return fcm.sendToDevice(token, payload);



});
