use hope;
/** create tables **/
CREATE TABLE domain (
 name varchar(255) PRIMARY KEY,
 label varchar(255)
);

CREATE TABLE subdomain(
 domain varchar(255) REFERENCES domain,
 name varchar(255),
 label varchar(255),
 PRIMARY KEY(domain, name),
 UNIQUE (name)
);

CREATE TABLE feature (
 name ENUM('f1', 'f2', 'f3') PRIMARY KEY,
 label varchar(255),
 enabled boolean
);

CREATE TABLE role(
 name varchar(255) PRIMARY KEY,
 features ENUM('f1', 'f2', 'f3') REFERENCES feature 
);

CREATE TABLE ice_user ( 
 nuid varchar(16) PRIMARY KEY,
 system boolean,
 name varchar(255),
 email varchar(255),
 roles varchar(255) REFERENCES role,
 subdomains varchar(255),
 FOREIGN KEY (subdomains) REFERENCES subdomain(name)
);

CREATE TABLE fulfillment_configuration (
 subdomain varchar(255) REFERENCES subdomain(name),
 name varchar(255),
 state ENUM ('new', 'draft', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 enabled boolean,
 psp_letter_id varchar(255),
 constants json,
 PRIMARY KEY (subdomain, name),
 UNIQUE (name)
);


CREATE TABLE field_type (
 name varchar(255) PRIMARY KEY,
 state ENUM ('new', 'draft', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 type ENUM ('ft1', 'ft2', 'ft3'), -- NOT NULL DEFAUT 'ft1' ,
 raw_character_length integer,
 pattern varchar(255),
 message varchar(255)
);

CREATE TABLE standard_variable (
 name VARCHAR(255) PRIMARY KEY,
 label VARCHAR(255),
 field_type varchar(255) REFERENCES field_type
);

CREATE TABLE style_sheet (
 name varchar(255),
 version integer,
 label varchar(255),
 state ENUM('new', 'draft', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 domain varchar(255) REFERENCES domain,
 subdomain varchar(255) REFERENCES subdomain(name),
 fragments varchar(255),
 base_templates varchar(255),
 document_templates varchar(255),
 data varchar(255),
 PRIMARY KEY (name, version),
 UNIQUE(name)
);

CREATE TABLE variable (
 subdomain varchar(255) REFERENCES subdomain(name),
 name varchar(255),
 state ENUM('new', 'draft', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 field_type varchar(255) REFERENCES field_type,
 always_provided boolean,
 standard_variable VARCHAR(255) REFERENCES standard_variable,
 fragments varchar(255),
 base_templates varchar(255),
 document_templates varchar(255),
 contexts varchar(255),
 PRIMARY KEY (subdomain, name),
 UNIQUE (name),
 UNIQUE(subdomain)
);

CREATE TABLE context (
 subdomain varchar(255), 
 name varchar(255),
 state ENUM('new', 'draft', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 label varchar(255),
 variables varchar(255) REFERENCES variable(name),
 templates varchar(255),
 PRIMARY KEY (subdomain, name),
 UNIQUE(name)
);


CREATE TABLE image (
 name varchar(255) PRIMARY KEY,
 label varchar(255),
 state ENUM('new', 'draft', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 domain varchar(255) REFERENCES domain,
 subdomain varchar(255) REFERENCES subdomain(name),
 fragments varchar(255),
 mime_type varchar(255),
 image varbinary(8000)
);


CREATE TABLE fragment (
 name varchar(255),
 version integer,
 label varchar(255),
state ENUM('new', 'draft', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 domain varchar(255) REFERENCES domain,
 subdomain varchar(255) REFERENCES subdomain(name),
 style_sheet varchar(255) REFERENCES style_sheet(name),
 variable varchar(255) REFERENCES variable (name),
 standard_variable varchar(255) REFERENCES standard_variable,
 image varchar(255) REFERENCES image,
 base_templates varchar(255),
 document_templates varchar(255),
 data varchar(255),
 PRIMARY KEY (name, version),
 UNIQUE (name)
);


 
CREATE TABLE base_template (
 subdomain varchar(255) REFERENCES subdomain(name),
 name varchar(255),
 version integer,
 label varchar(255),
state ENUM('new', 'draft', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 fragments varchar(255) REFERENCES fragment (name),
 style_sheets varchar(255) REFERENCES style_sheet(name),
 variables varchar(255) REFERENCES variable(name),
 standard_variables varchar(255) REFERENCES standard_variable,
 fulfillment_configuration varchar(255) REFERENCES fulfillment_configuration(name),
 data varchar(255),
 PRIMARY KEY (subdomain, name, version),
 UNIQUE(name)
);

CREATE TABLE document_template (
 base_template varchar(255) REFERENCES base_template(name),
 name varchar(255),
 version integer,
 label varchar(255),
 state ENUM ('new', 'draft', 'review', 'rejected', 'final', 'published', 'deactivated', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 approved_by varchar(16) REFERENCES ice_user,
 approved timestamp,
 published_by varchar(16) REFERENCES ice_user,
 published timestamp,
 fragments varchar(255) REFERENCES fragment(name),
 style_sheets varchar(255) REFERENCES style_sheet(name),
 variables varchar(255) REFERENCES variable(name),
 standard_variables varchar(255) REFERENCES standard_variable,
 standard_variable_sets varchar(255),
 contexts varchar(255) REFERENCES context(name),
 data varchar(255),
 PRIMARY KEY (base_template, name, version),
 UNIQUE (name)
);

CREATE TABLE standard_variable_set (
 name varchar(255) PRIMARY KEY,
 label varchar(255),
 standard_variables varchar(255) REFERENCES standard_variable,
 document_templates varchar(255) REFERENCES document_template(name)
);



CREATE TABLE document (
 id varchar(255) PRIMARY KEY,
 state ENUM ('new', 'draft', 'submitted', 'archived', 'deleted'), -- NOT NULL DEFAUT 'new' ,
 last_updated_by varchar(16) REFERENCES ice_user,
 last_updated timestamp,
 owner varchar(16) REFERENCES ice_user,
 security_delegate varchar(16),
 template varchar(255) REFERENCES document_template (name),
 data_record json,
 data varchar(255),
 image varbinary(8000)
);

/** create foreign keys for tables that have cyclic relationships **/
ALTER TABLE variable 
 ADD FOREIGN KEY (contexts) 
 REFERENCES context (name);
 
ALTER TABLE variable 
 ADD FOREIGN KEY (fragments) 
 REFERENCES fragment (name);
 
ALTER TABLE image 
 ADD FOREIGN KEY (fragments) 
 REFERENCES fragment (name);
 
ALTER TABLE style_sheet 
 ADD FOREIGN KEY (fragments) 
 REFERENCES fragment (name);
 
ALTER TABLE style_sheet 
 ADD FOREIGN KEY (base_templates) 
 REFERENCES base_template (name);
 
ALTER TABLE style_sheet 
 ADD FOREIGN KEY (document_templates) 
 REFERENCES document_template (name);

ALTER TABLE variable 
 ADD FOREIGN KEY (base_templates) 
 REFERENCES base_template (name);
 
ALTER TABLE variable 
 ADD FOREIGN KEY (document_templates) 
 REFERENCES document_template (name);

ALTER TABLE context 
 ADD FOREIGN KEY (templates) 
 REFERENCES document_template (name);

ALTER TABLE fragment 
 ADD FOREIGN KEY (base_templates) 
 REFERENCES base_template (name);
 
ALTER TABLE fragment 
 ADD FOREIGN KEY (document_templates) 
 REFERENCES document_template (name);

ALTER TABLE document_template 
 ADD FOREIGN KEY (standard_variable_sets) 
 REFERENCES standard_variable_set (name);
