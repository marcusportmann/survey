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
  DATA             TEXT NOT NULL,

  PRIMARY KEY (ID, VERSION),
  CONSTRAINT  SURVEY_SURVEY_DEFINITIONS_ORGANISATION_FK FOREIGN KEY (ORGANISATION_ID) REFERENCES MMP.ORGANISATIONS(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_DEFINITIONS_ORGANISATION_ID_IX
  ON SURVEY.SURVEY_DEFINITIONS
  (ORGANISATION_ID);

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.ID
IS 'The Universally Unique Identifier (UUID) used, along with the version of the survey definition, to uniquely identify the survey definition';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.VERSION
IS 'The version of the survey definition';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.ORGANISATION_ID
IS 'The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey definition is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.NAME
IS 'The name of the survey definition';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.DESCRIPTION
IS 'The description for the survey definition';

COMMENT ON COLUMN SURVEY.SURVEY_DEFINITIONS.DATA
IS 'The JSON data for the survey definition';



CREATE TABLE SURVEY.SURVEY_INSTANCES (
  ID                         UUID NOT NULL,
  SURVEY_DEFINITION_ID       UUID NOT NULL,
  SURVEY_DEFINITION_VERSION  INTEGER NOT NULL,
  NAME                       TEXT NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT  SURVEY_SURVEY_INSTANCES_SURVEY_DEFINITION_FK FOREIGN KEY (SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION) REFERENCES SURVEY.SURVEY_DEFINITIONS(ID, VERSION) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_INSTANCES_SURVEY_DEFINITION_IX
  ON SURVEY.SURVEY_INSTANCES
  (SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION);

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.ID
IS 'The Universally Unique Identifier (UUID) used  to uniquely identify the survey instance';

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.SURVEY_DEFINITION_ID
IS 'The Universally Unique Identifier (UUID) used, along with the version of the survey definition, to uniquely identify the survey definition this survey instance is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.SURVEY_DEFINITION_VERSION
IS 'The version of the survey definition this survey instance is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_INSTANCES.NAME
IS 'The name of the survey instance';



CREATE TABLE SURVEY.SURVEY_REQUESTS (
  ID                  UUID NOT NULL,
  SURVEY_INSTANCE_ID  UUID NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT  SURVEY_SURVEY_REQUESTS_SURVEY_INSTANCE_FK FOREIGN KEY (SURVEY_INSTANCE_ID) REFERENCES SURVEY.SURVEY_INSTANCES(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_REQUESTS_SURVEY_INSTANCE_ID_IX
  ON SURVEY.SURVEY_REQUESTS
  (SURVEY_INSTANCE_ID);

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.ID
IS 'The Universally Unique Identifier (UUID) used  to uniquely identify the survey template group member';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.SURVEY_INSTANCE_ID
IS 'The Universally Unique Identifier (UUID) used to uniquely  identify the survey template group this survey template group member is associated with';



CREATE TABLE SURVEY.SURVEY_RESPONSES (
  ID                  UUID NOT NULL,
  SURVEY_INSTANCE_ID  UUID NOT NULL,
  SURVEY_REQUEST_ID   UUID,
  DATA                TEXT NOT NULL,

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

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.DATA
IS 'The JSON data for the survey response';



CREATE TABLE SURVEY.SURVEY_AUDIENCES (
  ID               UUID NOT NULL,
  ORGANISATION_ID  UUID NOT NULL,
  NAME             TEXT NOT NULL,

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



CREATE TABLE SURVEY.SURVEY_AUDIENCE_MEMBERS (
  ID                  UUID NOT NULL,
  SURVEY_AUDIENCE_ID  UUID NOT NULL,
  FIRST_NAME          TEXT NOT NULL,
  LAST_NAME           TEXT NOT NULL,
  EMAIL               TEXT NOT NULL,

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
INSERT INTO MMP.ORGANISATIONS (ID, NAME) VALUES
  ('d077425e-c75f-4dd8-9d62-81f2d26b8a62', 'BAGL - Africa Technology - CTO');

INSERT INTO MMP.USER_DIRECTORIES (ID, TYPE_ID, NAME, CONFIGURATION) VALUES
  ('b229d620-bfd7-4a7b-926c-5041da432ae3', 'b43fda33-d3b0-4f80-a39a-110b8e530f4f', 'BAGL - Africa Technology - CTO', '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE userDirectory SYSTEM "UserDirectoryConfiguration.dtd"><userDirectory><parameter><name>MaxPasswordAttempts</name><value>5</value></parameter><parameter><name>PasswordExpiryMonths</name><value>12</value></parameter><parameter><name>PasswordHistoryMonths</name><value>24</value></parameter><parameter><name>MaxFilteredUsers</name><value>100</value></parameter></userDirectory>');

INSERT INTO MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (USER_DIRECTORY_ID, ORGANISATION_ID) VALUES
  ('4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62');
INSERT INTO MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (USER_DIRECTORY_ID, ORGANISATION_ID) VALUES
  ('b229d620-bfd7-4a7b-926c-5041da432ae3', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62');

INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Organisation Administrators', 'Organisation Administrators');

INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Organisation Administrators');

INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('44ff0ad2-fbe1-489f-86c9-cef7f82acf35', '5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6');

INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('20725a56-7103-4056-8c74-62f50239ccb7', 'Survey.SurveyAudienceAdministration', 'Survey Audience Administration', 'Survey Audience Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('381a0942-feb8-489f-b9f8-d65f90a7eab7', 'Survey.SurveyAdministration', 'Survey Administration', 'Survey Administration');

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('20725a56-7103-4056-8c74-62f50239ccb7', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Survey.SurveyAudienceAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('381a0942-feb8-489f-b9f8-d65f90a7eab7', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Survey.SurveyAdministration

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('20725a56-7103-4056-8c74-62f50239ccb7', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Survey.SurveyAudienceAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('381a0942-feb8-489f-b9f8-d65f90a7eab7', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Survey.SurveyAdministration





INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, DATA) VALUES
  ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'c1685b92-9fe5-453a-995b-89d8c0f29cb5', 'CTO ELT Values Survey', '', '{"id":"706fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"organisationId":"767c1abe-8aef-45c9-bcdf-81adf94406f5","name":"CTO ELT Values Survey","description":"CTO ELT Values Survey","sectionDefinitions":[],"groupDefinitions":[{"id":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","name":"CTO ELT","description":"CTO ELT","groupMemberDefinitions":[{"id":"404dac3f-dc8b-4331-8b92-96b4fdf72305","name":"CTO ELT"},{"id":"1311a54b-5995-4ec2-89b9-0375d3ac9fbb","name":"Peter"},{"id":"b86528a1-337c-4a79-8e71-d741d0c7c6ec","name":"Adriaan"},{"id":"bdb3e2e2-20b8-4895-aaee-facf8320a873","name":"Alapan"},{"id":"cc91f682-8532-42bc-8d41-60c65ec0ce92","name":"Dan"},{"id":"24960e6a-e39e-4783-9952-2ab0af353864","name":"Daryl"},{"id":"81a01568-3c52-4035-9882-4da16406fce5","name":"David"},{"id":"8e555ef1-5381-4181-ae60-a8b0dbae2ddd","name":"Francois"},{"id":"97cb3170-9d59-4168-a041-eb7d9caae24b","name":"James"},{"id":"85d24485-9eb2-45fa-b8ca-a2312ac89a22","name":"Kersh"},{"id":"43887881-1232-4b67-97bf-8a714909adf3","name":"Kevin"},{"id":"825f434c-8fbb-44ab-92c5-d251c1e07eac","name":"Linde-Marie"},{"id":"5f8f29c1-ac48-4a60-960b-cad4bb2600f2","name":"Manoj"},{"id":"1d404c58-fd76-4f07-ab93-97805386a81a","name":"Marcus"},{"id":"e156ead6-8237-4b88-ab51-77009911d9ac","name":"Mercia"},{"id":"ef762b41-c353-4ccf-948e-c819ca5b86b6","name":"Nicole"},{"id":"fbca627e-9ea9-4504-918a-4d52be5082d7","name":"Lawrence"},{"id":"84b544ec-e6a0-448f-85c2-93075d534270","name":"Richard"},{"id":"c6ff4f8a-b2aa-4d28-af64-5f1341642fde","name":"Sandra"},{"id":"a57e5114-dcde-44c9-9742-11b0dafea480","name":"Tendai"},{"id":"ce3f437a-e596-4cbc-a173-529b6f8af635","name":"Debbie"}]}],"groupRatingItemDefinitions":[{"id":"489dc868-1959-4790-83f2-85190d5a5522","name":"Accountability","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"d1f438d6-dd8a-4ab5-a532-861e062bc743","name":"Competence","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"42055a18-42a0-4cea-85ec-87b13bd472eb","name":"Courage","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"a1b0e2bc-70f3-45b5-918c-9ac51c0bc74f","name":"Fairness","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"1c38e533-8e21-4807-a629-60cc2272f128","name":"Integrity","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"28235bb2-d822-48da-802f-4f39ce1834f7","name":"Openness","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"3218579b-2c8d-47a9-bb37-963c598c55a2","name":"Positive Attitude","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"104884b0-3c37-44ed-a72c-49d2ce8457da","name":"Teamwork","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"006cf453-160b-445a-a012-038cc62cf88a","name":"Making a difference","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"c9590fa2-ea6d-4289-9fb1-42d98d227ee8","name":"Trust","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2}]}');

INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME) VALUES
  ('b222aa15-715f-4752-923d-8f33ee8a1736', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'CTO ELT Values Survey - September 2016');




INSERT INTO SURVEY.SURVEY_AUDIENCES (ID, ORGANISATION_ID, NAME) VALUES
  ('c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT');

INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('b2a72a4b-08f9-4740-aa5b-f7a5e690f0a9', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Peter', 'Rix', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('f6156984-6bbb-44b9-8a82-ee86dafbacc7', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Adriaan', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('ad7e91ae-1cee-4f91-b87a-6fde06e32acc', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Alapan', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('1cd8d426-6e75-4f93-bbc7-3992f4043bed', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Daniel', 'Acton', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('3eabd869-9b0e-437e-a826-d7af06834818', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Daryl', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('9bc1b70b-80f3-46d5-b30e-ebbe5de8656e', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'David', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('74ed0311-f884-4bd6-ae57-4421385a543a', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Francois', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('109b0cb3-54d6-41e6-a524-7105d31e6d27', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'James', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('a301b8ee-64e6-4c83-ac08-d96211a334a7', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Kershnee', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('3170afc3-6798-4849-9635-99365221d115', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Kevin', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('b0302932-6ddc-4c2a-a8c6-9dfa4c58b754', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Linde-Marie', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('51bbca64-785c-40a5-bef2-cfbc9fb503ef', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Manoj', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('2105161b-0ef3-44bc-a5de-be47124ef5e2', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Marcus', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('225677e0-0da3-4efc-827b-3ab268c46b87', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Mercia', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('c412061b-61c2-4c7d-9486-ccb09118af42', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Nicole', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('10f89240-acbc-4a39-901f-843871d332ee', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Lawrence', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('0a92616a-3e78-44f7-9f39-00213e2f1af8', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Richard', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('6f1978a2-3783-4a76-a964-50258f1c082c', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Sandra', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('8eae4a3a-8863-44cb-a417-13488d551b83', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Tendai', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('e9b5276f-e1aa-4c69-960a-f7022431108c', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Debbie', '', '');



