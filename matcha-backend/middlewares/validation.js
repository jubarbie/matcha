let required = (data, field, errors) => {
    if (!(data[field] && data[field] != undefined && data[field] != "")) {
        errors.push({
            field: field,
            validation: 'required',
            message: 'Field ' + field + ' is required'
        });
        return null;
    } else {
        return data[field];
    }
}

let isEmail = (data, field, errors) => {
    if (data[field]) {
        let m = data[field].match(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
        if (m == null) {
            errors.push({
                field: field,
                validation: 'is email',
                message: 'Field ' + field + ' must be an email'
            });
        }
        return data[field];
    } else
        return null;
}

let isLength = (data, field, options, errors) => {
    if (data[field]) {
        if (options.min != undefined && Number.isInteger(options.min)) {
            if (!(data[field].length >= options.min)) {
                errors.push({
                    field: field,
                    validation: 'min length',
                    message: 'Field ' + field + ' must be minimum ' + options.min + ' length'
                });
            }
        }
        if (options.max != undefined && Number.isInteger(options.max)) {
            if (!(data[field].length <= options.max)) {
                errors.push({
                    field: field,
                    validation: 'max length',
                    message: 'Field ' + field + ' must be maximum ' + options.min + ' length'
                });
            }
        }
        return data[field];

    } else
        return null;
}

let isRegex = (data, field, reg, errors) => {
  if (data[field]) {
      let m = data[field].match(reg);
      if (m == null) {
          errors.push({
              field: field,
              validation: 'is regex',
              message: 'Field ' + field + ' must be like ' + reg.toString()
          });
      }
      return data[field];
  } else
      return null;
}

exports.validateNewUserInfos = (req) => {
  let valid = this.validateUserInfos(req);
  let infos = valid.data;
  let errors = valid.errors;
  let data = req.body;

  infos.username = required(data, 'username', errors);
  isRegex(data, 'username', /^[A-Za-z0-9_-]{2,}$/, errors);

  return {
      data: infos,
      valid: (errors.length == 0),
      errors: errors
  }
}

exports.validateUserInfos = (req) => {
    let infos = {};
    let errors = [];
    let data = req.body;

    infos.email = required(data, 'email', errors);
    isEmail(data, 'email', errors);
    infos.fname = required(data, 'fname', errors);
    isLength(data, 'fname', {
        min: 1,
        max: 255
    }, errors);
    infos.lname = required(data, 'lname', errors);
    isLength(data, 'lname', {
        min: 1,
        max: 255
    }, errors);
    infos.bio = (data['bio'] != undefined) ? data['bio'] : null;
    return {
        data: infos,
        valid: (errors.length == 0),
        errors: errors
    }
}
