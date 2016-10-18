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



-- -------------------------------------------------------------------------------------------------
-- POPULATE TABLES
-- -------------------------------------------------------------------------------------------------
INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, DATA) VALUES
  ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'c1685b92-9fe5-453a-995b-89d8c0f29cb5', 'CTO ELT Values Survey', '', '{"id":"706fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"organisationId":"767c1abe-8aef-45c9-bcdf-81adf94406f5","name":"CTO ELT Values Survey","description":"CTO ELT Values Survey","sectionDefinitions":[],"groupDefinitions":[{"id":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","name":"CTO ELT","description":"CTO ELT","groupMemberDefinitions":[{"id":"404dac3f-dc8b-4331-8b92-96b4fdf72305","name":"CTO ELT"},{"id":"1311a54b-5995-4ec2-89b9-0375d3ac9fbb","name":"Peter"},{"id":"b86528a1-337c-4a79-8e71-d741d0c7c6ec","name":"Adriaan"},{"id":"bdb3e2e2-20b8-4895-aaee-facf8320a873","name":"Alapan"},{"id":"cc91f682-8532-42bc-8d41-60c65ec0ce92","name":"Dan"},{"id":"24960e6a-e39e-4783-9952-2ab0af353864","name":"Daryl"},{"id":"81a01568-3c52-4035-9882-4da16406fce5","name":"David"},{"id":"8e555ef1-5381-4181-ae60-a8b0dbae2ddd","name":"Francois"},{"id":"97cb3170-9d59-4168-a041-eb7d9caae24b","name":"James"},{"id":"85d24485-9eb2-45fa-b8ca-a2312ac89a22","name":"Kersh"},{"id":"43887881-1232-4b67-97bf-8a714909adf3","name":"Kevin"},{"id":"825f434c-8fbb-44ab-92c5-d251c1e07eac","name":"Linde-Marie"},{"id":"5f8f29c1-ac48-4a60-960b-cad4bb2600f2","name":"Manoj"},{"id":"1d404c58-fd76-4f07-ab93-97805386a81a","name":"Marcus"},{"id":"e156ead6-8237-4b88-ab51-77009911d9ac","name":"Mercia"},{"id":"ef762b41-c353-4ccf-948e-c819ca5b86b6","name":"Nicole"},{"id":"fbca627e-9ea9-4504-918a-4d52be5082d7","name":"Lawrence"},{"id":"84b544ec-e6a0-448f-85c2-93075d534270","name":"Richard"},{"id":"c6ff4f8a-b2aa-4d28-af64-5f1341642fde","name":"Sandra"},{"id":"a57e5114-dcde-44c9-9742-11b0dafea480","name":"Tendai"},{"id":"ce3f437a-e596-4cbc-a173-529b6f8af635","name":"Debbie"}]}],"groupRatingItemDefinitions":[{"id":"489dc868-1959-4790-83f2-85190d5a5522","name":"Accountability","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"d1f438d6-dd8a-4ab5-a532-861e062bc743","name":"Competence","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"42055a18-42a0-4cea-85ec-87b13bd472eb","name":"Courage","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"a1b0e2bc-70f3-45b5-918c-9ac51c0bc74f","name":"Fairness","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"1c38e533-8e21-4807-a629-60cc2272f128","name":"Integrity","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"28235bb2-d822-48da-802f-4f39ce1834f7","name":"Openness","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"3218579b-2c8d-47a9-bb37-963c598c55a2","name":"Positive Attitude","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"104884b0-3c37-44ed-a72c-49d2ce8457da","name":"Teamwork","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"006cf453-160b-445a-a012-038cc62cf88a","name":"Making a difference","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2},{"id":"c9590fa2-ea6d-4289-9fb1-42d98d227ee8","name":"Trust","groupDefinitionId":"f44270e1-cf88-40c3-9a5e-2a09cd7b34df","ratingType":2}]}');

INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME) VALUES
  ('b222aa15-715f-4752-923d-8f33ee8a1736', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'CTO ELT Values Survey - September 2016');

