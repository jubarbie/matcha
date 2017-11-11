var nodemailer = require('nodemailer');

var mailer = {};

mailer.sendVerifEmail = function (mailTo, login, key) {

  nodemailer.createTestAccount((err, account) => {

    // create reusable transporter object using the default SMTP transport
    let transporter = nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        secure: false, // true for 465, false for other ports
        auth: {
            user: account.user, // generated ethereal user
            pass: account.pass  // generated ethereal password
        }
    });

    // setup email data with unicode symbols
    let mailOptions = {
        from: '"DARKROOM" <noreply@darkroom.com>', // sender address
        to: mailTo, // list of receivers
        subject: 'Welcome into the DARKROOM', // Subject line
        html: '<b>Please verify you email by clicking on this <a href="http://localhost:3001/api/users/user/'+login+'/emailverif?r='+key+'">link</a></b>' // html body
    };

    // send mail with defined transport object
    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            return console.log(error);
        }
        console.log('Message sent: %s', info.messageId);
        // Preview only available when sending through an Ethereal account
        console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));

    });

  });
};

module.exports = mailer;
