-- -------------------------------------------------------------------------------------------------
-- CREATE SCHEMAS
-- -------------------------------------------------------------------------------------------------
CREATE SCHEMA SURVEY;



-- -------------------------------------------------------------------------------------------------
-- CREATE TABLES
-- -------------------------------------------------------------------------------------------------
CREATE TABLE SURVEY.SURVEY_DEFINITIONS (
  ID               UUID NOT NULL,
  VERSION          INTEGER NOT NULL,
  ORGANISATION_ID  UUID NOT NULL,
  NAME             TEXT NOT NULL,
  DESCRIPTION      TEXT NOT NULL,
  ANONYMOUS        BOOLEAN NOT NULL,
  DATA             TEXT NOT NULL,

	PRIMARY KEY (ID, VERSION),
	CONSTRAINT  SURVEY_SURVEY_DEFINITIONS_ORGANISATION_FK FOREIGN KEY (ORGANISATION_ID) REFERENCES MMP.ORGANISATIONS(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_DEFINITIONS_ORGANISATION_ID_IX
  ON SURVEY.SURVEY_DEFINITIONS
  (ORGANISATION_ID);

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.ID
  IS 'The Universally Unique Identifier (UUID) used to, along with the version of the survey definition, uniquely identify the survey definition';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.VERSION
  IS 'The version of the survey definition';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.ORGANISATION_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey definition is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.NAME
  IS 'The name of the survey definition';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.DESCRIPTION
  IS 'The description for the survey definition';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.ANONYMOUS
  IS 'Is the survey definition anonymous';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.DATA
  IS 'The JSON data for the survey definition';



CREATE TABLE SURVEY.SURVEY_INSTANCES (
  ID                         UUID NOT NULL,
  SURVEY_DEFINITION_ID       UUID NOT NULL,
  SURVEY_DEFINITION_VERSION  INTEGER NOT NULL,
  NAME                       TEXT NOT NULL,
  DESCRIPTION                TEXT NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT  SURVEY_SURVEY_INSTANCES_SURVEY_DEFINITION_FK FOREIGN KEY (SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION) REFERENCES SURVEY.SURVEY_DEFINITIONS(ID, VERSION) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_INSTANCES_SURVEY_DEFINITION_IX
  ON SURVEY.SURVEY_INSTANCES
  (SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION);

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey instance';

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.SURVEY_DEFINITION_ID
  IS 'The Universally Unique Identifier (UUID) used to, along with the version of the survey definition, uniquely identify the survey definition this survey instance is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.SURVEY_DEFINITION_VERSION
  IS 'The version of the survey definition this survey instance is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.NAME
  IS 'The name of the survey instance';

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.DESCRIPTION
  IS 'The description for the survey instance';



CREATE TABLE SURVEY.SURVEY_REQUESTS (
  ID                  UUID NOT NULL,
  SURVEY_INSTANCE_ID  UUID NOT NULL,
  FIRST_NAME          VARCHAR(4000) NOT NULL,
  LAST_NAME           VARCHAR(4000) NOT NULL,
  EMAIL               VARCHAR(4000) NOT NULL,
  REQUESTED           TIMESTAMP NOT NULL,
  STATUS              INTEGER NOT NULL,
  SEND_ATTEMPTS       INTEGER NOT NULL DEFAULT 0,
  LOCK_NAME           TEXT,
  LAST_PROCESSED      TIMESTAMP,

  PRIMARY KEY (ID),
  CONSTRAINT  SURVEY_SURVEY_REQUESTS_SURVEY_INSTANCE_FK FOREIGN KEY (SURVEY_INSTANCE_ID) REFERENCES SURVEY.SURVEY_INSTANCES(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_REQUESTS_SURVEY_INSTANCE_ID_IX
  ON SURVEY.SURVEY_REQUESTS
  (SURVEY_INSTANCE_ID);

CREATE INDEX SURVEY_SURVEY_REQUESTS_EMAIL_IX
  ON SURVEY.SURVEY_REQUESTS
  (EMAIL);

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.ID
  IS 'The Universally Unique Identifier (UUID) used  to uniquely identify the survey request';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.SURVEY_INSTANCE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey instance the survey request is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.FIRST_NAME
  IS 'The first name(s) for the person who was requested to complete the survey';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.LAST_NAME
  IS 'The last name for the person who was requested to complete the survey';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.EMAIL
  IS 'The e-mail address for the person who was requested to complete the survey';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.REQUESTED
  IS 'The date and time the request to complete the survey was last requested';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.STATUS
  IS 'The status of the survey request';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.SEND_ATTEMPTS
  IS 'The number of times that the sending of the survey request was attempted';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.LOCK_NAME
  IS 'The name of the entity that has locked the survey request for sending';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.LAST_PROCESSED
  IS 'The date and time the last attempt was made to send the survey request';



CREATE TABLE SURVEY.SURVEY_RESPONSES (
  ID                  UUID NOT NULL,
  SURVEY_INSTANCE_ID  UUID NOT NULL,
  SURVEY_REQUEST_ID   UUID,
  RESPONDED           TIMESTAMP NOT NULL,
  DATA                CLOB NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT  SURVEY_SURVEY_RESPONSES_SURVEY_INSTANCE_FK FOREIGN KEY (SURVEY_INSTANCE_ID) REFERENCES SURVEY.SURVEY_INSTANCES(ID) ON DELETE CASCADE,
  CONSTRAINT  SURVEY_SURVEY_RESPONSES_SURVEY_REQUEST_FK FOREIGN KEY (SURVEY_REQUEST_ID) REFERENCES SURVEY.SURVEY_REQUESTS(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_RESPONSES_SURVEY_INSTANCE_ID_IX
  ON SURVEY.SURVEY_RESPONSES
  (SURVEY_INSTANCE_ID);

CREATE INDEX SURVEY_SURVEY_RESPONSES_SURVEY_REQUEST_ID_IX
  ON SURVEY.SURVEY_RESPONSES
  (SURVEY_REQUEST_ID);

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey response';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.SURVEY_INSTANCE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey instance the survey response is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.SURVEY_REQUEST_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey request the survey response is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.RESPONDED
  IS 'The date and time the survey response was responded';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.DATA
  IS 'The JSON data for the survey response';



CREATE TABLE SURVEY.SURVEY_AUDIENCES (
  ID               UUID NOT NULL,
  ORGANISATION_ID  UUID NOT NULL,
  NAME             VARCHAR(4000) NOT NULL,
  DESCRIPTION      VARCHAR(4000) NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT  SURVEY_SURVEY_AUDIENCES_ORGANISATION_FK FOREIGN KEY (ORGANISATION_ID) REFERENCES MMP.ORGANISATIONS(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_AUDIENCES_ORGANISATION_ID_IX
  ON SURVEY.SURVEY_AUDIENCES
  (ORGANISATION_ID);

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCES.ID
  IS 'The Universally Unique Identifier (UUID) used  to uniquely identify the survey audience';

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCES.ORGANISATION_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey audience is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCES.NAME
  IS 'The name of the survey audience';

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCES.DESCRIPTION
  IS 'The description for the survey audience';



CREATE TABLE SURVEY.SURVEY_AUDIENCE_MEMBERS (
  ID                  UUID NOT NULL,
  SURVEY_AUDIENCE_ID  UUID NOT NULL,
  FIRST_NAME          VARCHAR(4000) NOT NULL,
  LAST_NAME           VARCHAR(4000) NOT NULL,
  EMAIL               VARCHAR(4000) NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT  SURVEY_SURVEY_AUDIENCE_MEMBERS_SURVEY_AUDIENCE_FK FOREIGN KEY (SURVEY_AUDIENCE_ID) REFERENCES SURVEY.SURVEY_AUDIENCES(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_AUDIENCE_MEMBERS_SURVEY_AUDIENCE_ID_IX
  ON SURVEY.SURVEY_AUDIENCE_MEMBERS
  (SURVEY_AUDIENCE_ID);

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCE_MEMBERS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey audience member';

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCE_MEMBERS.SURVEY_AUDIENCE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey audience the survey audience member is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCE_MEMBERS.FIRST_NAME
  IS 'The first name(s) for the survey audience member';

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCE_MEMBERS.LAST_NAME
  IS 'The last name for the survey audience member';

COMMENT ON COLUMN SURVEY.SURVEY_AUDIENCE_MEMBERS.EMAIL
  IS 'The e-mail address for the survey audience member';



-- -------------------------------------------------------------------------------------------------
-- POPULATE TABLES
-- -------------------------------------------------------------------------------------------------
INSERT INTO MMP.ROLES (ID, NAME, DESCRIPTION) VALUES
  ('313bf6a4-b58a-4979-a2e3-50ee74b84b32', 'Survey Administrator', 'Survey Administrator');
INSERT INTO MMP.ROLES (ID, NAME, DESCRIPTION) VALUES
  ('fd140749-2f7b-4e25-b5de-c10bc878f355', 'Survey Viewer', 'Survey Viewer');

INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('20725a56-7103-4056-8c74-62f50239ccb7', 'Survey.SurveyAudienceAdministration', 'Survey Audience Administration', 'Survey Audience Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('381a0942-feb8-489f-b9f8-d65f90a7eab7', 'Survey.SurveyAdministration', 'Survey Administration', 'Survey Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('2d25184e-39e5-451b-b4c9-62fe109a71e2', 'Survey.ViewSurveyResponse', 'View Survey Response', 'View Survey Response');

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('20725a56-7103-4056-8c74-62f50239ccb7', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Survey.SurveyAudienceAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('381a0942-feb8-489f-b9f8-d65f90a7eab7', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Survey.SurveyAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2d25184e-39e5-451b-b4c9-62fe109a71e2', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Survey.ViewSurveyResponse

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('20725a56-7103-4056-8c74-62f50239ccb7', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Survey.SurveyAudienceAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('381a0942-feb8-489f-b9f8-d65f90a7eab7', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Survey.SurveyAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2d25184e-39e5-451b-b4c9-62fe109a71e2', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Survey.ViewSurveyResponse

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2a43152c-d8ae-4b08-8ad9-2448ec5debd5', '313bf6a4-b58a-4979-a2e3-50ee74b84b32'); -- Application.SecureHome
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('f4e3b387-8cd1-4c56-a2da-fe39a78a56d9', '313bf6a4-b58a-4979-a2e3-50ee74b84b32'); -- Application.Dashboard
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('20725a56-7103-4056-8c74-62f50239ccb7', '313bf6a4-b58a-4979-a2e3-50ee74b84b32'); -- Survey.SurveyAudienceAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('381a0942-feb8-489f-b9f8-d65f90a7eab7', '313bf6a4-b58a-4979-a2e3-50ee74b84b32'); -- Survey.SurveyAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2d25184e-39e5-451b-b4c9-62fe109a71e2', '313bf6a4-b58a-4979-a2e3-50ee74b84b32'); -- Survey.ViewSurveyResponse

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2a43152c-d8ae-4b08-8ad9-2448ec5debd5', 'fd140749-2f7b-4e25-b5de-c10bc878f355'); -- Application.SecureHome
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('f4e3b387-8cd1-4c56-a2da-fe39a78a56d9', 'fd140749-2f7b-4e25-b5de-c10bc878f355'); -- Application.Dashboard
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2d25184e-39e5-451b-b4c9-62fe109a71e2', 'fd140749-2f7b-4e25-b5de-c10bc878f355'); -- Survey.ViewSurveyResponse






INSERT INTO MMP.ORGANISATIONS (ID, NAME, STATUS) VALUES
  ('d077425e-c75f-4dd8-9d62-81f2d26b8a62', 'BAGL - Africa Technology - CTO', 1);

INSERT INTO MMP.USER_DIRECTORIES (ID, TYPE_ID, NAME, CONFIGURATION) VALUES
  ('b229d620-bfd7-4a7b-926c-5041da432ae3', 'b43fda33-d3b0-4f80-a39a-110b8e530f4f', 'BAGL - Africa Technology - CTO', '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE userDirectory SYSTEM "UserDirectoryConfiguration.dtd"><userDirectory><parameter><name>MaxPasswordAttempts</name><value>5</value></parameter><parameter><name>PasswordExpiryMonths</name><value>12</value></parameter><parameter><name>PasswordHistoryMonths</name><value>24</value></parameter><parameter><name>MaxFilteredUsers</name><value>100</value></parameter></userDirectory>');

INSERT INTO MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (USER_DIRECTORY_ID, ORGANISATION_ID) VALUES
  ('4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62');
INSERT INTO MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (USER_DIRECTORY_ID, ORGANISATION_ID) VALUES
  ('b229d620-bfd7-4a7b-926c-5041da432ae3', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62');

INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Organisation Administrators', 'Organisation Administrators');
INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('74bd122c-74d9-4e40-95b8-0550f54a0267', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Survey Administrators', 'Survey Administrators');
INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('82b72c08-6544-41bd-93dd-f82c74477376', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Survey Viewers', 'Survey Viewers');

INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Organisation Administrators');
INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('74bd122c-74d9-4e40-95b8-0550f54a0267', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Survey Administrators');
INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('82b72c08-6544-41bd-93dd-f82c74477376', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Survey Viewers');

INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('44ff0ad2-fbe1-489f-86c9-cef7f82acf35', '5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6');
INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('313bf6a4-b58a-4979-a2e3-50ee74b84b32', '74bd122c-74d9-4e40-95b8-0550f54a0267');
INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('fd140749-2f7b-4e25-b5de-c10bc878f355', '82b72c08-6544-41bd-93dd-f82c74477376');







--INSERT INTO MMP.INTERNAL_USERS (ID, USER_DIRECTORY_ID, USERNAME, PASSWORD, FIRST_NAME, LAST_NAME, PHONE, MOBILE, EMAIL,
--PASSWORD_ATTEMPTS, PASSWORD_EXPIRY) VALUES
--  ('0a8a997e-5899-4445-9201-d4f811069ac7', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'test1',
--'GVE/3J2k+3KkoF62aRdUjTyQ/5TVQZ4fI2PuqJ3+4d0=', '', '', '', '', '', null, null);
--INSERT INTO MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (INTERNAL_USER_ID, INTERNAL_GROUP_ID) VALUES
--  ('0a8a997e-5899-4445-9201-d4f811069ac7', '74bd122c-74d9-4e40-95b8-0550f54a0267');

--INSERT INTO MMP.INTERNAL_USERS (ID, USER_DIRECTORY_ID, USERNAME, PASSWORD, FIRST_NAME, LAST_NAME, PHONE, MOBILE, EMAIL,
--PASSWORD_ATTEMPTS, PASSWORD_EXPIRY) VALUES
--  ('aceba07e-97bf-47a8-a876-c774ad038f8b', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'test2',
--'GVE/3J2k+3KkoF62aRdUjTyQ/5TVQZ4fI2PuqJ3+4d0=', '', '', '', '', '', null, null);
--INSERT INTO MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (INTERNAL_USER_ID, INTERNAL_GROUP_ID) VALUES
--  ('aceba07e-97bf-47a8-a876-c774ad038f8b', '82b72c08-6544-41bd-93dd-f82c74477376');




























--INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, ANONYMOUS, DATA) VALUES
--  ('806fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'Anonymous CTO ELT Values', 'Anonymous CTO ELT --Values', TRUE, '{}');
--INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME, DESCRIPTION) VALUES
--  ('43ba05e3-f6dd-40f2-9a63-9f201158e68c', '806fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'Anonymous CTO ELT Values - December 2016',
--'Anonymous CTO ELT Values - December 2016');





INSERT INTO SURVEY.SURVEY_AUDIENCES (ID, ORGANISATION_ID, NAME, DESCRIPTION) VALUES
  ('b41a2db8-0da8-420a-bce3-a1ce4af49661', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'Test', 'Test');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('2105161b-0ef3-44bc-a5de-be47124ef5e2', 'b41a2db8-0da8-420a-bce3-a1ce4af49661', 'Marcus', 'Portmann', 'marcus@mmp.guru');





INSERT INTO SURVEY.SURVEY_AUDIENCES (ID, ORGANISATION_ID, NAME, DESCRIPTION) VALUES
  ('c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT', 'CTO ELT');

INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('b2a72a4b-08f9-4740-aa5b-f7a5e690f0a9', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Peter', 'Rix', 'peter.rix@absacapital.com');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('f6156984-6bbb-44b9-8a82-ee86dafbacc7', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Adriaan', 'Van Heerden', 'Adriaan.VanHeerden@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('ad7e91ae-1cee-4f91-b87a-6fde06e32acc', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Alapan', 'Arnab', 'Alapan.Arnab@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('dea8681b-8093-4069-9a25-5385ab5dbbbc', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Claus', 'Tepper', 'Claus.Tepper@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('1cd8d426-6e75-4f93-bbc7-3992f4043bed', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Daniel', 'Acton', 'Daniel.Acton@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('3eabd869-9b0e-437e-a826-d7af06834818', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Daryl', 'Kingwill', 'Daryl.Kingwill@barclayscapital.com');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('9bc1b70b-80f3-46d5-b30e-ebbe5de8656e', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'David', 'Donald', 'David.Donald@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('028d93f6-10eb-4f10-8156-8f9daf828b96', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Duncan', 'Macdonald', 'Duncan.Macdonald2@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('74ed0311-f884-4bd6-ae57-4421385a543a', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Francois', 'Cilliers', 'Francois.Cilliers@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('109b0cb3-54d6-41e6-a524-7105d31e6d27', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'James', 'Knupfer', 'james.knupfer2@barclayscorp.com');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('dad3d00b-fe10-4065-a322-5dcf5772e688', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Karen', 'Williams', 'Karen.Williams@barclayscapital.com');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('a301b8ee-64e6-4c83-ac08-d96211a334a7', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Kershnee', 'Naidoo Kisten', 'Kershnee.NaidooKisten@barclayscapital.com');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('3170afc3-6798-4849-9635-99365221d115', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Kevin', 'Rolfe', 'Kevin.Rolfe@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('10f89240-acbc-4a39-901f-843871d332ee', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Lawrence', 'Kuveya', 'Lawrence.Kuveya@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('51bbca64-785c-40a5-bef2-cfbc9fb503ef', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Manoj', 'Puri', 'Manoj.Puri@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('225677e0-0da3-4efc-827b-3ab268c46b87', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Mercia', 'Dube', 'Mercia.Dube@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('b0302932-6ddc-4c2a-a8c6-9dfa4c58b754', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Manish', 'Dullabh', 'Manish.Dullabh@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('c412061b-61c2-4c7d-9486-ccb09118af42', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Nicole', 'Cader', 'Nicole.Cader@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('0a92616a-3e78-44f7-9f39-00213e2f1af8', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Richard', 'Himlok', 'Richard.Himlok@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('6f1978a2-3783-4a76-a964-50258f1c082c', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Sandra', 'La Bella', 'sandralb@barclaysafrica.com');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('8eae4a3a-8863-44cb-a417-13488d551b83', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Tendai', 'Dube', 'Tendai.Dube@absa.co.za');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('e9b5276f-e1aa-4c69-960a-f7022431108c', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Deborah', 'Mitchell', 'Deborah.Mitchell@barclayscapital.com');






































INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, ANONYMOUS, DATA) VALUES ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT Values', 'CTO ELT Values', FALSE, '{"id":"706fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"name":"CTO ELT Values","description":"CTO ELT Values","groupDefinitions":[],"itemDefinitions":[{"typeId":"aded36bd-bc3d-4157-99f6-b4d91825de5d","id":"b996cda3-cb79-41ef-a59e-1647dd6f4aff","typeId":"aded36bd-bc3d-4157-99f6-b4d91825de5d","name":"cto_values","label":"CTO Values","description":"CTO Values","help":"CTO Values","groupRatingDefinitions":[{"id":"2e2dd08e-7f3f-4cf8-a541-6b444cbd46cf","name":"Accountability","ratingType":2},{"id":"ea5c8bfe-f5e9-4671-b187-27bb57560465","name":"Competence","ratingType":2},{"id":"d8d4b131-9446-415a-9014-a695872abaee","name":"Courage","ratingType":2},{"id":"005734be-efae-4e10-9566-4b8082d7b70d","name":"Fairness","ratingType":2},{"id":"9a813873-6807-40af-9355-b63ecdd7cb4f","name":"Integrity","ratingType":2},{"id":"ba2a0d45-f900-4a38-994e-a909c5972cd1","name":"Openness","ratingType":2},{"id":"5f5f02e1-5d4c-4d2b-8f5e-d44b75048cca","name":"Positive Attitude","ratingType":2},{"id":"139ebeda-4eb3-4775-bfbf-1764a24eb819","name":"Teamwork","ratingType":2},{"id":"61a7d2df-b254-4923-965a-30544b6731f3","name":"Making a Difference","ratingType":2},{"id":"8125c4d0-8e08-4e1d-9113-2f12ff7081e3","name":"Trust","ratingType":2}],"groupMemberDefinitions":[{"id":"ac403554-bb29-4427-8716-329a7e6facab","name":"CTO ELT"},{"id":"776cadb8-e6c5-4432-8cc7-7a9c5294e7ea","name":"Peter"},{"id":"18feeeb5-6f46-48e1-863e-d53e280abc76","name":"Adriaan"},{"id":"086004ee-3104-4f01-aa48-593aee134282","name":"Alapan"},{"id":"c994914e-53f8-41f0-b3c6-e7566a36b1c6","name":"Claus"},{"id":"d77f0ff6-ef30-4ccc-b0d7-d429500d34ce","name":"Daniel"},{"id":"6afe2786-11d9-40c0-bd7d-93eaf6e419b6","name":"Daryl"},{"id":"8fbb97b7-b72f-4e36-b992-6144f423c1f2","name":"David"},{"id":"87f9836b-a0a5-4b00-a065-60af802303ff","name":"Duncan"},{"id":"8792443e-4739-44fa-9973-1d43e03a89cb","name":"Francois"},{"id":"625f0b52-23d7-462f-bb61-0707079193bf","name":"James"},{"id":"0153a859-4d4a-4cc8-a242-985f392098a9","name":"Karen"},{"id":"d9b85eb9-0f8d-417b-b245-21d3847c2cda","name":"Kershnee"},{"id":"08ad4279-75d6-4966-9e21-3a5d836db574","name":"Kevin"},{"id":"3a6700e2-b0d8-4dea-9cbb-9b8b25501d75","name":"Lawrence"},{"id":"2898c865-b2df-40f8-81d0-7646fa166383","name":"Manoj"},{"id":"3a5ca5cc-5f89-4b92-9dc1-9b97704b1120","name":"Mercia"},{"id":"396cfb69-2232-4356-bd73-50b21e630596","name":"Manish"},{"id":"ff813324-dfd2-4519-97d2-5f701ff59f6b","name":"Nicole"},{"id":"1085a738-4ecd-43b6-a89f-71491046537d","name":"Richard"},{"id":"971424cb-6756-4cc4-b8ba-600f79b8a2f3","name":"Sandra"},{"id":"f3fae5b6-86a3-483a-8f43-a08a653bf93c","name":"Tendai"},{"id":"f70ac61d-4ac5-4472-8ffb-9afc20ec208c","name":"Deborah"}],"displayRatingsUsingGradient":true}]}');

INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME, DESCRIPTION) VALUES ('b1842f3a-ab2c-4741-ad24-0015100a7293', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'CTO ELT Values - January 2017', 'CTO ELT Values - September 2016');

