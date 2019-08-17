SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
CREATE SCHEMA IF NOT EXISTS `eathappy` DEFAULT CHARACTER SET latin1 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`user` (
  `username` (16) NOT NULL,
  `email` (255) NULL,
  `password` (32) NOT NULL,
  `create_time`  NULL DEFAULT CURRENT_TIMESTAMP);

USE `eathappy` ;

-- -----------------------------------------------------
-- Table `eathappy`.`categories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`categories` (
  `category_id` INT(11) NOT NULL AUTO_INCREMENT,
  `category_name` VARCHAR(45) NOT NULL,
  `category_type` ENUM('p', 's') NOT NULL,
  `category_label` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE INDEX `name` (`category_name` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COMMENT = 'Categories used in collections and applied to recipes';


-- -----------------------------------------------------
-- Table `eathappy`.`collections`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`collections` (
  `collection_id` INT(11) NOT NULL AUTO_INCREMENT,
  `collection_name` VARCHAR(45) NOT NULL,
  `private` TINYINT(1) NOT NULL,
  `collection_label` VARCHAR(45) NULL DEFAULT NULL COMMENT 'collectionName - URL-based name' /* comment truncated */ /*collection_label - label fo dsiplay*/,
  `default_sort_position` INT(3) NULL DEFAULT NULL,
  PRIMARY KEY (`collection_id`),
  UNIQUE INDEX `name` (`collection_name` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COMMENT = 'Sets of recipes';


-- -----------------------------------------------------
-- Table `eathappy`.`collection_categories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`collection_categories` (
  `collection_id` INT(11) NOT NULL,
  `category_id` INT(11) NOT NULL,
  `sort_position` INT(3) NULL DEFAULT NULL,
  PRIMARY KEY (`collection_id`, `category_id`),
  INDEX `collection_id_idx` (`collection_id` ASC),
  INDEX `category_id_idx` (`category_id` ASC),
  CONSTRAINT `collection_id`
    FOREIGN KEY (`collection_id`)
    REFERENCES `eathappy`.`collections` (`collection_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `category_id`
    FOREIGN KEY (`category_id`)
    REFERENCES `eathappy`.`categories` (`category_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COMMENT = 'Used to control display on entry,  this table is crap in the';


-- -----------------------------------------------------
-- Table `eathappy`.`editors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`editors` (
  `editor_id` INT(11) NOT NULL,
  `login` VARCHAR(45) NOT NULL,
  `first_name` VARCHAR(20) NOT NULL,
  `last_name` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`editor_id`),
  UNIQUE INDEX `login` (`login` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `eathappy`.`collection_editors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`collection_editors` (
  `collection_id` INT(11) NOT NULL,
  `editor_id` INT(11) NOT NULL,
  PRIMARY KEY (`collection_id`, `editor_id`),
  INDEX `c_eeditor_id` (`editor_id` ASC),
  INDEX `c_ecollection_iD` (`collection_id` ASC),
  CONSTRAINT `CEeditor_id`
    FOREIGN KEY (`editor_id`)
    REFERENCES `eathappy`.`editors` (`editor_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `CEcollection_iD`
    FOREIGN KEY (`collection_id`)
    REFERENCES `eathappy`.`collections` (`collection_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COMMENT = 'Those permitted to make edits to this category.  Might later';


-- -----------------------------------------------------
-- Table `eathappy`.`sources`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`sources` (
  `source_id` INT(11) NOT NULL AUTO_INCREMENT,
  `source_type` VARCHAR(15) NOT NULL,
  `source_title` VARCHAR(45) NOT NULL,
  `source_lname` VARCHAR(45) NULL DEFAULT NULL,
  `source_fname` VARCHAR(90) NULL DEFAULT NULL,
  `publisher` VARCHAR(45) NULL DEFAULT NULL,
  `source_city` VARCHAR(45) NULL DEFAULT NULL,
  `source_year` SMALLINT(4) NULL DEFAULT NULL,
  PRIMARY KEY (`source_id`),
  UNIQUE INDEX `name` (`source_title` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `eathappy`.`recipe_citations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`recipe_citations` (
  `citation_id` INT(11) NOT NULL AUTO_INCREMENT,
  `recipe_id` INT(11) NULL DEFAULT NULL,
  `source_id` INT(11) NULL DEFAULT NULL,
  `author_lname` VARCHAR(90) NOT NULL,
  `author_fname` VARCHAR(45) NULL DEFAULT NULL,
  `citation_recipe_name` VARCHAR(90) NULL DEFAULT NULL,
  `source_date` DATE NULL DEFAULT NULL,
  `page_number` TINYINT NULL DEFAULT NULL,
  `citation_url` VARCHAR(256) NULL DEFAULT NULL,
  `url_access_date` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`citation_id`),
  UNIQUE INDEX `author_lname_UNIQUE` (`author_lname` ASC),
  INDEX `fk_citations_sources1_idx` (`source_id` ASC),
  CONSTRAINT `fk_citations_sources1`
    FOREIGN KEY (`source_id`)
    REFERENCES `eathappy`.`sources` (`source_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `eathappy`.`yield_units`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`yield_units` (
  `yield_unit_id` INT(11) NOT NULL AUTO_INCREMENT,
  `yield_unit_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`yield_unit_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `eathappy`.`recipes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`recipes` (
  `recipe_id` INT(11) NOT NULL AUTO_INCREMENT,
  `recipe_name` VARCHAR(90) NOT NULL,
  `yield_quant` SMALLINT(5) NULL DEFAULT NULL,
  `yield_unit_id` INT(11) NULL DEFAULT NULL,
  `prep_time` VARCHAR(45) NULL DEFAULT NULL,
  `notes` TEXT NULL DEFAULT NULL,
  `preparation` TEXT NOT NULL,
  `source_id` INT(11) NULL DEFAULT NULL,
  `source_page` SMALLINT(6) NULL DEFAULT NULL,
  `source_date` DATE NULL DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `last_update` DATETIME NOT NULL,
  PRIMARY KEY (`recipe_id`),
  UNIQUE INDEX `Recipe_name` (`recipe_name` ASC),
  INDEX `source_iD_idx` (`source_id` ASC),
  INDEX `yield_unit_iD_idx` (`yield_unit_id` ASC),
  CONSTRAINT `source_iD`
    FOREIGN KEY (`source_id`)
    REFERENCES `eathappy`.`recipe_citations` (`source_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `yield_unit_iD`
    FOREIGN KEY (`yield_unit_id`)
    REFERENCES `eathappy`.`yield_units` (`yield_unit_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `eathappy`.`collection_recipe_categories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`collection_recipe_categories` (
  `collection_id` INT(11) NOT NULL,
  `recipe_id` INT(11) NOT NULL,
  `category_id` INT(11) NOT NULL,
  PRIMARY KEY (`collection_id`, `recipe_id`, `category_id`),
  INDEX `c_rCcategory_iD_idx` (`category_id` ASC),
  INDEX `c_rCcollection_iD_idx` (`collection_id` ASC),
  INDEX `c_rCrecipe_id_idx` (`recipe_id` ASC),
  CONSTRAINT `c_rCcategory_iD`
    FOREIGN KEY (`category_id`)
    REFERENCES `eathappy`.`categories` (`category_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `c_rCcollection_iD`
    FOREIGN KEY (`collection_id`)
    REFERENCES `eathappy`.`collections` (`collection_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `c_rCrecipe_id`
    FOREIGN KEY (`recipe_id`)
    REFERENCES `eathappy`.`recipes` (`recipe_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COMMENT = 'Categories per recipe per collection';


-- -----------------------------------------------------
-- Table `eathappy`.`collection_recipes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`collection_recipes` (
  `collection_id` INT(11) NOT NULL,
  `recipe_id` INT(11) NOT NULL,
  `date_added` DATE NOT NULL,
  `untried` TINYINT(1) NOT NULL,
  `deleted` TINYINT(1) NOT NULL,
  PRIMARY KEY (`collection_id`, `recipe_id`),
  INDEX `CRcollection_id_idx` (`collection_id` ASC),
  INDEX `CRrecipe_id_idx` (`recipe_id` ASC),
  CONSTRAINT `CRcollection_id`
    FOREIGN KEY (`collection_id`)
    REFERENCES `eathappy`.`collections` (`collection_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `CRrecipe_id`
    FOREIGN KEY (`recipe_id`)
    REFERENCES `eathappy`.`recipes` (`recipe_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COMMENT = 'Recipes in a collection';


-- -----------------------------------------------------
-- Table `eathappy`.`ingredient_measures`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`ingredient_measures` (
  `measure_id` INT(11) NOT NULL AUTO_INCREMENT,
  `measure_abbrev` VARCHAR(45) NOT NULL,
  `measure_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`measure_id`),
  UNIQUE INDEX `meas_abbrev` USING BTREE (`measure_abbrev` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 12
DEFAULT CHARACTER SET = latin1
COMMENT = 'Units';


-- -----------------------------------------------------
-- Table `eathappy`.`ingredient_preparations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`ingredient_preparations` (
  `preparation_id` INT(11) NOT NULL AUTO_INCREMENT,
  `ingred_prep_desc` VARCHAR(126) NOT NULL,
  PRIMARY KEY (`preparation_id`),
  UNIQUE INDEX `Prep_name` (`ingred_prep_desc` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 10
DEFAULT CHARACTER SET = latin1
COMMENT = '<-- NO SHIT InnoDB free: 9216 kB';


-- -----------------------------------------------------
-- Table `eathappy`.`ingredients`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`ingredients` (
  `ingredient_id` INT(11) NOT NULL AUTO_INCREMENT,
  `ingredient_name` VARCHAR(128) NOT NULL,
  PRIMARY KEY (`ingredient_id`),
  UNIQUE INDEX `Ingred_name` (`ingredient_name` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 15
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `eathappy`.`recipe_editors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`recipe_editors` (
  `editor_id` INT(11) NOT NULL,
  `recipe_id` INT(11) NOT NULL,
  `last_update` DATE NOT NULL,
  INDEX `editor_iD_idx` (`editor_id` ASC),
  INDEX `recipe_id_idx` (`recipe_id` ASC),
  PRIMARY KEY (`editor_id`, `recipe_id`),
  CONSTRAINT `editor_iD`
    FOREIGN KEY (`editor_id`)
    REFERENCES `eathappy`.`editors` (`editor_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `recipe_id`
    FOREIGN KEY (`recipe_id`)
    REFERENCES `eathappy`.`recipes` (`recipe_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `eathappy`.`recipe_ingredients`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `eathappy`.`recipe_ingredients` (
  `recipe_ingredient_id` INT(11) NOT NULL AUTO_INCREMENT,
  `recipe_id` INT(11) NOT NULL,
  `` SMALLINT(5) NOT NULL COMMENT 'Should be \'sequence\', but clashes with our toolset',
  `ingredient_id` INT(11) NOT NULL,
  `measure_quant` VARCHAR(16) NULL DEFAULT NULL COMMENT 'measurementQuant should be numeric -- too many fishy values in there now...',
  `measure_id` INT(11) NULL DEFAULT NULL,
  `preparation_id` INT(11) NULL DEFAULT NULL,
  `divider` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`recipe_ingredient_id`),
  UNIQUE INDEX `Sequence_check` USING BTREE (`recipe_id` ASC, `` ASC),
  INDEX `RIingredient_id_idx` (`` ASC),
  INDEX `RIpreparation_id_idx` (`` ASC),
  INDEX `RImeasurement_id_idx` (`` ASC),
  INDEX `RIrecipe_id_idx` (`recipe_id` ASC),
  CONSTRAINT `RIingredient_id`
    FOREIGN KEY (``)
    REFERENCES `eathappy`.`ingredients` (`ingredient_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `RIpreparation_id`
    FOREIGN KEY (``)
    REFERENCES `eathappy`.`ingredient_preparations` (`preparation_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `RImeasurement_id`
    FOREIGN KEY (``)
    REFERENCES `eathappy`.`ingredient_measures` (`measure_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `RIrecipe_id`
    FOREIGN KEY (`recipe_id`)
    REFERENCES `eathappy`.`recipes` (`recipe_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = latin1;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

