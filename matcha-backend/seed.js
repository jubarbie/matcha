const UsersModel = require('./models/users_model');
const ImageModel = require('./models/image_model');
const TagModel = require('./models/tag_model');
const config = require('./config');
const bcrypt = require('bcrypt');
const loremIpsum = require('lorem-ipsum');
const faker = require('faker/locale/en');
const tags_file = require('./tags.json');
const imgs_path = './public/upload/images/';
const fs = require('fs');

if (process.argv.length != 3) {
    console.log("Usage: node add_user.js (0-1000)");
    process.exit();
} else if (Number(process.argv[2]) === NaN) {
    console.log("Usage: node add_user.js (0-1000)");
    process.exit();
} else if (process.argv[2] < 0 || process.argv[2] > 1000) {
    console.log("Usage: node add_user.js (0-1000)");
    process.exit();
}

const saltRounds = 10;
const max = Number(process.argv[2]);
const genders = ['M', 'F', 'NB', 'O'];
const images = fs.readdirSync(imgs_path).filter(img => {
    return (img.charAt(0) != '.')
});
const tags = tags_file.tags;
const tags_length = tags.length;

let admin = {
    login: "admin",
    lname: "Barbier",
    fname: "Jules",
    email: "jubarbie@student.42.fr",
    password: bcrypt.hashSync("admin", saltRounds),
    activated: "activated",
    rights: 0,
    gender: 'M',
    bio: 'I am the administrator of the app',
    localisation: JSON.stringify({
        lon: 2.318501,
        lat: 48.896607
    }),
    birth: 1986
}
async function create_database(admin, max) {
    process.stdout.write('Creating fake profiles [');
    await build_profile(admin);
    process.stdout.write('\u2592');
    await insert_random_profiles(max);
    console.log("Done !");
    process.exit();
}

async function insert_random_profiles(max) {

    faker.seed(max);
    let bar = 0;
    let bar_size = 20;
    let bar_quotien = max / bar_size;

    for (let i = 0; i < max; i++) {

        let user = {};

        user.login = faker.internet.userName();
        user.lname = faker.name.lastName();
        user.fname = faker.name.firstName();
        user.email = faker.internet.email();
        let pwd = user.login + "_PWD";
        user.password = bcrypt.hashSync(pwd, saltRounds);
        user.activated = "activated";
        user.rights = 1;
        user.gender = genders[get_random_num(0, 3)];
        user.bio = faker.lorem.paragraphs(get_random_num(1, 5));
        user.localisation = get_random_loc(2.271423, 48.840317, 2.409439, 48.901741);
        user.birth = get_random_num(1918, 1980);
        //let date = get_random_num(1492189607000, 1523725608000);

        await build_profile(user);
        if (Math.floor(i / bar_quotien) > bar) {
            process.stdout.write('\u2592');
            bar++;
        }
    }
    process.stdout.write('] ');
}

async function build_profile(user) {
    await insert_user(user)
        .then(result => {
            user.id = result.insertId
            //console.log(user.login + " inserted")
        }).catch(err => console.log(err));
    await add_tags(user).then(row => {
        //console.log("Tags added for " + user.login)
    }).catch(err => console.log(err));
    await add_images(user).then(row => {
        //console.log("Images added for " + user.login)
    }).catch(err => console.log(err));
    await add_sexuality(user).then(row => {
        //console.log("Sexuality added for " + user.login)
    }).catch(err => console.log(err));
}

async function add_tags(user) {
    let tags_nb = get_random_num(1, 21);
    for (var i = 0; i < tags_nb; i++) {
        let tag = tags[get_random_num(0, (tags_length - 1))];
        await insert_tag(user, tag);
    }
}

let insert_tag = (user, tag) => {
    return new Promise((resolve, reject) => {
        TagModel.addTag(user.login, tag, (err, rows, fields) => {
            if (!err) {
                return resolve(rows);
            } else {
                return reject(err);
            }
        });

    });
}

async function add_images(user) {
    let imgs_nb = get_random_num(1, 5);
    let images_to_insert = [];
    for (var i = 0; i < imgs_nb; i++) {
        let image = images[get_random_num(0, (images.length - 1))];
        while (images_to_insert.indexOf(image) >= 0) {
            image = images[get_random_num(0, (images.length - 1))];
        }
        images_to_insert.push(image);
        await insert_image(user, image).then(result => {
            UsersModel.updateField(user.login, 'img_id', result.insertId);
        }).catch(err => console.log(err));
    }
}

let insert_image = (user, image) => {
    return new Promise((resolve, reject) => {
        ImageModel.addImage(user.id, image, (err, result) => {
            if (!err) {
                return resolve(result);
            } else {
                return reject(err);
            }
        });
    });
}

async function add_sexuality(user) {
    let int_in_nb = get_random_num(1, genders.length);
    let int_in = [];
    for (var i = 0; i < int_in_nb; i++) {
        let gender = [user.login, genders[get_random_num(0, (genders.length - 1))]];
        while (int_in.indexOf(gender) >= 0) {
            gender = [user.login, genders[get_random_num(0, (genders.length - 1))]];
        }
        int_in.push(gender);
    }
    return new Promise((resolve, reject) => {
        UsersModel.updateSexuality(user.login, int_in, (err, result) => {
            if (!err) {
                return resolve(result);
            } else {
                return reject(err);
            }
        });
    });
}

let insert_user = (user) => {
    return new Promise((resolve, reject) => {
        now = Date.now();
        UsersModel.insertFullUser(user, now, (err, result) => {
            if (!err) {
                return resolve(result);
            } else {
                return reject(err);
            }
        });

    });
}

let get_random_bio = (max) => {
    let bio = loremIpsum({
        count: max,
        units: 'sentences',
        sentenceLowerBound: 5,
        sentenceUpperBound: 15,
        paragraphLowerBound: 3,
        paragraphUpperBound: 7,
        format: 'plain'
    });
    return bio;
}

function get_random_num(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function get_random_loc(min_lon, min_lat, max_lon, max_lat) {
    var loc = {};
    loc.lon = parseFloat((Math.random() * (max_lon - min_lon) + min_lon).toFixed(12));
    loc.lat = parseFloat((Math.random() * (max_lat - min_lat) + min_lat).toFixed(12));
    return JSON.stringify(loc);
}

create_database(admin, max);
