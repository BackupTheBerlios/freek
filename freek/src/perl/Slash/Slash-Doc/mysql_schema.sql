# A KISS document manager system

DROP TABLE IF EXISTS documents;
CREATE TABLE documents (
	document_id int(11) DEFAULT '0' NOT NULL auto_increment,
	uid int(11) NOT NULL, 
	name varchar(64),
	file varchar(64),
	size float,
	project_id int(11) NOT NULL,
	sid varchar(32),
	comments varchar(255),
	format_id int(11),
	sello timestamp,
	PRIMARY KEY (document_id)
);
