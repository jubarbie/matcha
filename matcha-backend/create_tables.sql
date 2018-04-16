CREATE TABLE IF NOT EXISTS `blocks` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `user_from` varchar(255) DEFAULT NULL,
  `user_to` varchar(255) DEFAULT NULL,
  `date` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=175 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `image` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `src` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=165 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `likes` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `user_from` varchar(255) DEFAULT NULL,
  `user_to` varchar(255) DEFAULT NULL,
  `date` varchar(200) DEFAULT NULL,
  `last` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=231 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `message` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `id_talk` int(6) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `date` varchar(200) NOT NULL,
  `message` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=363 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `rel_user_image` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `id_user` int(6) unsigned NOT NULL,
  `id_image` int(6) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=235 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `rel_user_tag` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(255) DEFAULT NULL,
  `tag` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=668 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `reports` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `user_from` varchar(255) DEFAULT NULL,
  `user_to` varchar(255) DEFAULT NULL,
  `date` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=174 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `sessions` (
  `sid` varchar(255) NOT NULL,
  `session` varchar(255) NOT NULL,
  `expires` datetime NOT NULL,
  PRIMARY KEY (`sid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `sex_orientation` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(255) DEFAULT NULL,
  `gender` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=543 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `talk` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `username1` varchar(255) DEFAULT NULL,
  `username2` varchar(255) DEFAULT NULL,
  `user1_last` varchar(200) DEFAULT NULL,
  `user2_last` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `unlikes` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `user_from` varchar(255) DEFAULT NULL,
  `user_to` varchar(255) DEFAULT NULL,
  `date` varchar(200) DEFAULT NULL,
  `last` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=232 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `user` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(255) DEFAULT NULL,
  `password` text,
  `fname` varchar(255) NOT NULL,
  `lname` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `gender` varchar(2) DEFAULT NULL,
  `bio` text,
  `activated` varchar(255) DEFAULT NULL,
  `rights` int(1) DEFAULT NULL,
  `created_on` varchar(255) DEFAULT NULL,
  `localisation` varchar(250) DEFAULT NULL,
  `last_connection` varchar(200) NOT NULL,
  `birth` year(4) DEFAULT NULL,
  `uuid` varchar(255) DEFAULT NULL,
  `img_id` int(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=139 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `visits` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `user_from` varchar(255) DEFAULT NULL,
  `user_to` varchar(255) DEFAULT NULL,
  `last` varchar(200) DEFAULT NULL,
  `date` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=266 DEFAULT CHARSET=utf8mb4;
