-- -------------------------------------------------------------------------------------------------
-- NOTE: When changing this file you may also need to modify the following file:
--       - ApplicationPostgres.sql (mmp-application)
--
--  Execute the following command to start the database server if it is not running:
--
--    OS X: pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/postgres.log start 
--    CentOS (as root): service postgresql-9.4 start 
--
--  Execute the following command to create the database:
--
--    OS X: createdb  --template=template0 --encoding=UTF8 surveydb
--    CentOS (as root): sudo su postgres -c 'createdb --template=template1 --encoding=UTF8 surveydb'
--
--  Execute the following command to initialise the database:
--
--    OS X: psql -d surveydb -f SurveyPostgres.sql
--    CentOS (as root): su postgres -c 'psql -d surveydb -f ApplicationPostgres.sql'
--
--  Execute the following command to delete the database:
--
--    OS X: dropdb surveydb
--    CentOS (as root): su postgres -c 'dropdb surveydb'
--
--  Execute the following command to clean-up unreferenced large objects on the database:
--
--    OS X: vacuumlo surveydb
--    CentOS (as root): su postgres -c 'vacuumlo surveydb'
--
-- -------------------------------------------------------------------------------------------------
set client_min_messages='warning';

-- -------------------------------------------------------------------------------------------------
-- DROP TABLES
-- -------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_RESPONSES CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_REQUESTS CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_TEMPLATE_GROUPS CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_TEMPLATES CASCADE;

DROP TABLE IF EXISTS MMP.SMS CASCADE;
DROP TABLE IF EXISTS MMP.REPORT_DEFINITIONS CASCADE;
DROP TABLE IF EXISTS MMP.CACHED_CODES CASCADE;
DROP TABLE IF EXISTS MMP.CACHED_CODE_CATEGORIES CASCADE;
DROP TABLE IF EXISTS MMP.CODES CASCADE;
DROP TABLE IF EXISTS MMP.CODE_CATEGORIES CASCADE;
DROP TABLE IF EXISTS MMP.JOB_PARAMETERS CASCADE;
DROP TABLE IF EXISTS MMP.JOBS CASCADE;
DROP TABLE IF EXISTS MMP.ROLE_TO_GROUP_MAP CASCADE;
DROP TABLE IF EXISTS MMP.FUNCTION_TO_ROLE_MAP CASCADE;
DROP TABLE IF EXISTS MMP.ROLES CASCADE;
DROP TABLE IF EXISTS MMP.FUNCTIONS CASCADE;
DROP TABLE IF EXISTS MMP.GROUPS CASCADE;
DROP TABLE IF EXISTS MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP CASCADE;
DROP TABLE IF EXISTS MMP.INTERNAL_GROUPS CASCADE;
DROP TABLE IF EXISTS MMP.INTERNAL_USERS_PASSWORD_HISTORY CASCADE;
DROP TABLE IF EXISTS MMP.INTERNAL_USERS CASCADE;
DROP TABLE IF EXISTS MMP.USER_DIRECTORY_TO_ORGANISATION_MAP CASCADE;
DROP TABLE IF EXISTS MMP.USER_DIRECTORIES CASCADE;
DROP TABLE IF EXISTS MMP.USER_DIRECTORY_TYPES CASCADE;
DROP TABLE IF EXISTS MMP.ORGANISATIONS CASCADE;
DROP TABLE IF EXISTS MMP.SERVICE_REGISTRY CASCADE;
DROP TABLE IF EXISTS MMP.REGISTRY CASCADE;
DROP TABLE IF EXISTS MMP.CONFIG CASCADE;
DROP TABLE IF EXISTS MMP.IDGENERATOR CASCADE;



-- -------------------------------------------------------------------------------------------------
-- DROP SCHEMAS
-- -------------------------------------------------------------------------------------------------
DROP SCHEMA IF EXISTS MMP CASCADE;
DROP SCHEMA IF EXISTS SURVEY CASCADE;



-- -------------------------------------------------------------------------------------------------
-- DROP ROLES
-- -------------------------------------------------------------------------------------------------
DROP OWNED BY survey CASCADE;
DROP ROLE IF EXISTS survey;



-- -------------------------------------------------------------------------------------------------
-- CREATE ROLES
-- -------------------------------------------------------------------------------------------------
CREATE ROLE survey WITH LOGIN PASSWORD 'Password1';
ALTER ROLE survey WITH LOGIN;



-- -------------------------------------------------------------------------------------------------
-- CREATE PROCEDURES
-- -------------------------------------------------------------------------------------------------
--
-- CREATE OR REPLACE FUNCTION bytea_import(p_path text, p_result out bytea)
--                    language plpgsql as $$
-- declare
--   l_oid oid;
--   r record;
-- begin
--   p_result := '';
--   select lo_import(p_path) into l_oid;
--   for r in ( select data
--              from pg_largeobject
--              where loid = l_oid
--              order by pageno ) loop
--     p_result = p_result || r.data;
--   end loop;
--   perform lo_unlink(l_oid);
-- end;$$;



-- -------------------------------------------------------------------------------------------------
-- CREATE SCHEMAS
-- -------------------------------------------------------------------------------------------------
CREATE SCHEMA MMP;
CREATE SCHEMA SURVEY;



-- -------------------------------------------------------------------------------------------------
-- CREATE TABLES
-- -------------------------------------------------------------------------------------------------
CREATE TABLE MMP.IDGENERATOR (
  NAME     TEXT NOT NULL,
  CURRENT  BIGINT DEFAULT 0,

  PRIMARY KEY (NAME)
);

COMMENT ON COLUMN MMP.IDGENERATOR.NAME
  IS 'The name giving the type of entity associated with the generated ID';

COMMENT ON COLUMN MMP.IDGENERATOR.CURRENT
  IS 'The current ID for the type';



CREATE TABLE MMP.CONFIG (
  KEY          TEXT NOT NULL,
  VALUE        TEXT NOT NULL,
  DESCRIPTION  TEXT NOT NULL,

  PRIMARY KEY (KEY)
);

COMMENT ON COLUMN MMP.CONFIG.KEY
  IS 'The key used to uniquely identify the configuration value';

COMMENT ON COLUMN MMP.CONFIG.VALUE
  IS 'The value for the configuration value';

COMMENT ON COLUMN MMP.CONFIG.DESCRIPTION
  IS 'The description for the configuration value';



CREATE TABLE MMP.REGISTRY (
  ID          UUID NOT NULL,
  PARENT_ID   UUID,
  ENTRY_TYPE  INTEGER NOT NULL,
  NAME        TEXT NOT NULL,
  SVALUE      TEXT,
  IVALUE      INTEGER,
  DVALUE      DECIMAL(16,12),
  BVALUE      BYTEA,

  PRIMARY KEY (ID)
);

CREATE INDEX MMP_REGISTRY_NAME_IX
  ON MMP.REGISTRY
  (NAME);

CREATE INDEX MMP_REGISTRY_PARENT_ID_IX
  ON MMP.REGISTRY
  (PARENT_ID);

COMMENT ON COLUMN MMP.REGISTRY.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the registry entry';

COMMENT ON COLUMN MMP.REGISTRY.PARENT_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the parent entry for the registry entry';

COMMENT ON COLUMN MMP.REGISTRY.ENTRY_TYPE
  IS 'The type of registry entry';

COMMENT ON COLUMN MMP.REGISTRY.NAME
  IS 'The name of the registry entry';

COMMENT ON COLUMN MMP.REGISTRY.SVALUE
  IS 'The string value for the registry entry';

COMMENT ON COLUMN MMP.REGISTRY.IVALUE
  IS 'The integer value for the registry entry';

COMMENT ON COLUMN MMP.REGISTRY.DVALUE
  IS 'The decimal value for the registry entry';

COMMENT ON COLUMN MMP.REGISTRY.BVALUE
  IS 'The binary value for the registry entry';



CREATE TABLE MMP.SERVICE_REGISTRY (
  NAME                  TEXT NOT NULL,
  SECURITY_TYPE         INTEGER NOT NULL,
  REQUIRES_USER_TOKEN   CHAR(1) NOT NULL,
	SUPPORTS_COMPRESSION  CHAR(1) NOT NULL,
	ENDPOINT              TEXT NOT NULL,
  SERVICE_CLASS         TEXT NOT NULL,
  WSDL_LOCATION         TEXT NOT NULL,
  USERNAME              TEXT,
  PASSWORD              TEXT,

	PRIMARY KEY (NAME)
);

COMMENT ON COLUMN MMP.SERVICE_REGISTRY.NAME
  IS 'The name used to uniquely identify the web service';

COMMENT ON COLUMN MMP.SERVICE_REGISTRY.SECURITY_TYPE
  IS 'The type of security model implemented by the web service i.e. 0 = None, 1 = WS-Security X509 Certificates, 2 = WS-Security Username Token, 3 = Client SSL, 4 = HTTP Authentication';

COMMENT ON COLUMN MMP.SERVICE_REGISTRY.REQUIRES_USER_TOKEN
  IS 'Does the web service require a user security token';

COMMENT ON COLUMN MMP.SERVICE_REGISTRY.SUPPORTS_COMPRESSION
  IS 'Does the web service support compression';

COMMENT ON COLUMN MMP.SERVICE_REGISTRY.ENDPOINT
  IS 'The endpoint for the web service';

COMMENT ON COLUMN MMP.SERVICE_REGISTRY.SERVICE_CLASS
  IS 'The fully qualified name of the Java service class';

COMMENT ON COLUMN MMP.SERVICE_REGISTRY.WSDL_LOCATION
  IS 'The location of the WSDL defining the web service on the classpath';



CREATE TABLE MMP.ORGANISATIONS (
  ID    UUID NOT NULL,
  NAME  TEXT NOT NULL,

  PRIMARY KEY (ID)
);

CREATE INDEX MMP_ORGANISATIONS_NAME_IX
  ON MMP.ORGANISATIONS
  (NAME);

COMMENT ON COLUMN MMP.ORGANISATIONS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the organisation';

COMMENT ON COLUMN MMP.ORGANISATIONS.NAME
  IS 'The name of the organisation';



CREATE TABLE MMP.USER_DIRECTORY_TYPES (
  ID                    UUID NOT NULL,
  NAME                  TEXT NOT NULL,
  USER_DIRECTORY_CLASS  TEXT NOT NULL,
  ADMINISTRATION_CLASS  TEXT NOT NULL,

  PRIMARY KEY (ID)
);

COMMENT ON COLUMN MMP.USER_DIRECTORY_TYPES.ID
IS 'The Universally Unique Identifier (UUID) used to uniquely identify the user directory type';

COMMENT ON COLUMN MMP.USER_DIRECTORY_TYPES.NAME
IS 'The name of the user directory type';

COMMENT ON COLUMN MMP.USER_DIRECTORY_TYPES.USER_DIRECTORY_CLASS
IS 'The fully qualified name of the Java class that implements the user directory type';

COMMENT ON COLUMN MMP.USER_DIRECTORY_TYPES.ADMINISTRATION_CLASS
IS 'The fully qualified name of the Java class that implements the Wicket component used to administer the configuration for the user directory type';



CREATE TABLE MMP.USER_DIRECTORIES (
  ID             UUID NOT NULL,
  TYPE_ID        UUID NOT NULL,
  NAME           TEXT NOT NULL,
  CONFIGURATION  TEXT NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT MMP_USER_DIRECTORIES_USER_DIRECTORY_TYPE_FK FOREIGN KEY (TYPE_ID) REFERENCES MMP.USER_DIRECTORY_TYPES(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_USER_DIRECTORIES_NAME_IX
  ON MMP.USER_DIRECTORIES
  (NAME);

COMMENT ON COLUMN MMP.USER_DIRECTORIES.ID
IS 'The Universally Unique Identifier (UUID) used to uniquely identify the user directory';

COMMENT ON COLUMN MMP.USER_DIRECTORIES.TYPE_ID
IS 'The Universally Unique Identifier (UUID) used to uniquely identify the user directory type';

COMMENT ON COLUMN MMP.USER_DIRECTORIES.NAME
IS 'The name of the user directory';

COMMENT ON COLUMN MMP.USER_DIRECTORIES.CONFIGURATION
IS 'The XML configuration data for the user directory';



CREATE TABLE MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (
  USER_DIRECTORY_ID  UUID NOT NULL,
  ORGANISATION_ID    UUID NOT NULL,

  PRIMARY KEY (USER_DIRECTORY_ID, ORGANISATION_ID),
  CONSTRAINT MMP_USER_DIRECTORY_TO_ORGANISATION_MAP_USER_DIRECTORY_FK FOREIGN KEY (USER_DIRECTORY_ID) REFERENCES MMP.USER_DIRECTORIES(ID) ON DELETE CASCADE,
  CONSTRAINT MMP_USER_DIRECTORY_TO_ORGANISATION_MAP_ORGANISATION_FK FOREIGN KEY (ORGANISATION_ID) REFERENCES MMP.ORGANISATIONS(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_USER_DIRECTORY_TO_ORGANISATION_MAP_USER_DIRECTORY_ID_IX
  ON MMP.USER_DIRECTORY_TO_ORGANISATION_MAP
  (USER_DIRECTORY_ID);

CREATE INDEX MMP_USER_DIRECTORY_TO_ORGANISATION_MAP_ORGANISATION_ID_IX
  ON MMP.USER_DIRECTORY_TO_ORGANISATION_MAP
  (ORGANISATION_ID);

COMMENT ON COLUMN MMP.USER_DIRECTORY_TO_ORGANISATION_MAP.USER_DIRECTORY_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the user directory';

COMMENT ON COLUMN MMP.USER_DIRECTORY_TO_ORGANISATION_MAP.ORGANISATION_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the organisation';



CREATE TABLE MMP.INTERNAL_USERS (
  ID                 UUID NOT NULL,
  USER_DIRECTORY_ID  UUID NOT NULL,
  USERNAME           TEXT NOT NULL,
  PASSWORD           TEXT,
  FIRST_NAME         TEXT,
  LAST_NAME          TEXT,
  PHONE              TEXT,
  MOBILE             TEXT,
  EMAIL              TEXT,
  PASSWORD_ATTEMPTS  INTEGER,
  PASSWORD_EXPIRY    TIMESTAMP,

  PRIMARY KEY (ID),
  CONSTRAINT MMP_INTERNAL_USERS_USER_DIRECTORY_FK FOREIGN KEY (USER_DIRECTORY_ID) REFERENCES MMP.USER_DIRECTORIES(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_INTERNAL_USERS_USER_DIRECTORY_ID_IX
  ON MMP.INTERNAL_USERS
  (USER_DIRECTORY_ID);

CREATE UNIQUE INDEX MMP_INTERNAL_USERS_USERNAME_IX
  ON MMP.INTERNAL_USERS
  (USERNAME);

COMMENT ON COLUMN MMP.INTERNAL_USERS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.USER_DIRECTORY_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the user directory the internal user is associated with';

COMMENT ON COLUMN MMP.INTERNAL_USERS.USERNAME
  IS 'The username for the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.PASSWORD
  IS 'The password for the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.FIRST_NAME
  IS 'The first name for the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.LAST_NAME
  IS 'The last name for the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.PHONE
  IS 'The phone number for the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.MOBILE
  IS 'The mobile number for the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.EMAIL
  IS 'The e-mail address for the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.PASSWORD_ATTEMPTS
  IS 'The number of failed attempts to authenticate the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS.PASSWORD_EXPIRY
  IS 'The date and time that the internal user''s password expires';



CREATE TABLE MMP.INTERNAL_USERS_PASSWORD_HISTORY (
  ID                UUID NOT NULL,
  INTERNAL_USER_ID  UUID NOT NULL,
  CHANGED           TIMESTAMP NOT NULL,
  PASSWORD          TEXT,

  PRIMARY KEY (ID),
  CONSTRAINT MMP_INTERNAL_USERS_PASSWORD_HISTORY_INTERNAL_USER_ID_FK FOREIGN KEY (INTERNAL_USER_ID) REFERENCES MMP.INTERNAL_USERS(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_INTERNAL_USERS_PASSWORD_HISTORY_INTERNAL_USER_ID_IX
  ON MMP.INTERNAL_USERS_PASSWORD_HISTORY
  (INTERNAL_USER_ID);

CREATE INDEX MMP_INTERNAL_USERS_PASSWORD_HISTORY_CHANGED_IX
  ON MMP.INTERNAL_USERS_PASSWORD_HISTORY
  (CHANGED);

COMMENT ON COLUMN MMP.INTERNAL_USERS_PASSWORD_HISTORY.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the password history entry';

COMMENT ON COLUMN MMP.INTERNAL_USERS_PASSWORD_HISTORY.INTERNAL_USER_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS_PASSWORD_HISTORY.CHANGED
  IS 'When the password change took place for the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USERS_PASSWORD_HISTORY.PASSWORD
  IS 'The password for the internal user';



CREATE TABLE MMP.INTERNAL_GROUPS (
  ID                 UUID NOT NULL,
  USER_DIRECTORY_ID  UUID NOT NULL,
  GROUPNAME          TEXT NOT NULL,
  DESCRIPTION        TEXT,

  PRIMARY KEY (ID),
  CONSTRAINT MMP_INTERNAL_GROUPS_USER_DIRECTORY_FK FOREIGN KEY (USER_DIRECTORY_ID) REFERENCES MMP.USER_DIRECTORIES(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_INTERNAL_GROUPS_USER_DIRECTORY_ID_IX
  ON MMP.INTERNAL_GROUPS
  (USER_DIRECTORY_ID);

CREATE INDEX MMP_INTERNAL_GROUPS_GROUPNAME_IX
  ON MMP.INTERNAL_GROUPS
  (GROUPNAME);

COMMENT ON COLUMN MMP.INTERNAL_GROUPS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the internal group';

COMMENT ON COLUMN MMP.INTERNAL_GROUPS.USER_DIRECTORY_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the user directory the internal group is associated with';

COMMENT ON COLUMN MMP.INTERNAL_GROUPS.GROUPNAME
  IS 'The group name for the internal group';

COMMENT ON COLUMN MMP.INTERNAL_GROUPS.DESCRIPTION
  IS 'A description for the internal group';



CREATE TABLE MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (
  INTERNAL_USER_ID   UUID NOT NULL,
  INTERNAL_GROUP_ID  UUID NOT NULL,

  PRIMARY KEY (INTERNAL_USER_ID, INTERNAL_GROUP_ID),
  CONSTRAINT MMP_INTERNAL_USER_TO_INTERNAL_GROUP_MAP_INTERNAL_USER_FK FOREIGN KEY (INTERNAL_USER_ID) REFERENCES MMP.INTERNAL_USERS(ID) ON DELETE CASCADE,
  CONSTRAINT MMP_INTERNAL_USER_TO_INTERNAL_GROUP_MAP_INTERNAL_GROUP_FK FOREIGN KEY (INTERNAL_GROUP_ID) REFERENCES MMP.INTERNAL_GROUPS(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_INTERNAL_USER_TO_INTERNAL_GROUP_MAP_INTERNAL_USER_ID_IX
  ON MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP
  (INTERNAL_USER_ID);

CREATE INDEX MMP_INTERNAL_USER_TO_INTERNAL_GROUP_MAP_INTERNAL_GROUP_ID_IX
  ON MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP
  (INTERNAL_GROUP_ID);

COMMENT ON COLUMN MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP.INTERNAL_USER_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the internal user';

COMMENT ON COLUMN MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP.INTERNAL_GROUP_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the internal group';



CREATE TABLE MMP.GROUPS (
  ID                 UUID NOT NULL,
  USER_DIRECTORY_ID  UUID NOT NULL,
  GROUPNAME          TEXT NOT NULL,

  PRIMARY KEY (ID)
);

CREATE INDEX MMP_GROUPS_USER_DIRECTORY_ID_IX
  ON MMP.GROUPS
  (USER_DIRECTORY_ID);

CREATE INDEX MMP_GROUPS_GROUPNAME_IX
  ON MMP.GROUPS
  (GROUPNAME);

COMMENT ON COLUMN MMP.GROUPS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the group';

COMMENT ON COLUMN MMP.GROUPS.USER_DIRECTORY_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the user directory the group is associated with';

COMMENT ON COLUMN MMP.GROUPS.GROUPNAME
  IS 'The group name for the group';



CREATE TABLE MMP.FUNCTIONS (
  ID           UUID NOT NULL,
  CODE         TEXT NOT NULL,
  NAME         TEXT NOT NULL,
  DESCRIPTION  TEXT,

  PRIMARY KEY (ID)
);

CREATE UNIQUE INDEX MMP_FUNCTIONS_CODE_IX
  ON MMP.FUNCTIONS
  (CODE);

COMMENT ON COLUMN MMP.FUNCTIONS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the function';

COMMENT ON COLUMN MMP.FUNCTIONS.CODE
  IS 'The unique code used to identify the function';

COMMENT ON COLUMN MMP.FUNCTIONS.NAME
  IS 'The name of the function';

COMMENT ON COLUMN MMP.FUNCTIONS.DESCRIPTION
  IS 'A description for the function';



CREATE TABLE MMP.ROLES (
  ID           UUID NOT NULL,
  NAME         TEXT NOT NULL,
  DESCRIPTION  TEXT,

  PRIMARY KEY (ID)
);

COMMENT ON COLUMN MMP.ROLES.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the role';

COMMENT ON COLUMN MMP.ROLES.NAME
  IS 'The name of the role';

COMMENT ON COLUMN MMP.ROLES.DESCRIPTION
  IS 'A description for the role';



CREATE TABLE MMP.FUNCTION_TO_ROLE_MAP (
  FUNCTION_ID  UUID NOT NULL,
  ROLE_ID      UUID NOT NULL,

  PRIMARY KEY (FUNCTION_ID, ROLE_ID),
  CONSTRAINT MMP_FUNCTION_TO_ROLE_MAP_FUNCTION_FK FOREIGN KEY (FUNCTION_ID) REFERENCES MMP.FUNCTIONS(ID) ON DELETE CASCADE,
  CONSTRAINT MMP_FUNCTION_TO_ROLE_MAP_ROLE_FK FOREIGN KEY (ROLE_ID) REFERENCES MMP.ROLES(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_FUNCTION_TO_ROLE_MAP_FUNCTION_ID_IX
  ON MMP.FUNCTION_TO_ROLE_MAP
  (FUNCTION_ID);

CREATE INDEX MMP_FUNCTION_TO_ROLE_MAP_ROLE_ID_IX
  ON MMP.FUNCTION_TO_ROLE_MAP
  (ROLE_ID);

COMMENT ON COLUMN MMP.FUNCTION_TO_ROLE_MAP.FUNCTION_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the function';

COMMENT ON COLUMN MMP.FUNCTION_TO_ROLE_MAP.ROLE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the role';



CREATE TABLE MMP.ROLE_TO_GROUP_MAP (
  ROLE_ID   UUID NOT NULL,
  GROUP_ID  UUID NOT NULL,

  PRIMARY KEY (ROLE_ID, GROUP_ID),
  CONSTRAINT MMP_ROLE_TO_GROUP_MAP_ROLE_FK FOREIGN KEY (ROLE_ID) REFERENCES MMP.ROLES(ID) ON DELETE CASCADE,
  CONSTRAINT MMP_ROLE_TO_GROUP_MAP_GROUP_FK FOREIGN KEY (GROUP_ID) REFERENCES MMP.GROUPS(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_ROLE_TO_GROUP_MAP_ROLE_ID_IX
  ON MMP.ROLE_TO_GROUP_MAP
  (ROLE_ID);

CREATE INDEX MMP_ROLE_TO_GROUP_MAP_GROUP_ID_IX
  ON MMP.ROLE_TO_GROUP_MAP
  (GROUP_ID);

COMMENT ON COLUMN MMP.ROLE_TO_GROUP_MAP.ROLE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the role';

COMMENT ON COLUMN MMP.ROLE_TO_GROUP_MAP.GROUP_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the group';



CREATE TABLE MMP.JOBS (
  ID                  UUID NOT NULL,
  NAME                TEXT NOT NULL,
  SCHEDULING_PATTERN  TEXT NOT NULL,
  JOB_CLASS           TEXT NOT NULL,
  IS_ENABLED          BOOLEAN NOT NULL,
  STATUS              INTEGER NOT NULL DEFAULT 1,
  EXECUTION_ATTEMPTS  INTEGER NOT NULL DEFAULT 0,
  LOCK_NAME           TEXT,
  LAST_EXECUTED       TIMESTAMP,
  NEXT_EXECUTION      TIMESTAMP,
  UPDATED             TIMESTAMP,

  PRIMARY KEY (ID)
);

COMMENT ON COLUMN MMP.JOBS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the job';

COMMENT ON COLUMN MMP.JOBS.NAME
  IS 'The name of the job';

COMMENT ON COLUMN MMP.JOBS.SCHEDULING_PATTERN
  IS 'The cron-style scheduling pattern for the job';

COMMENT ON COLUMN MMP.JOBS.JOB_CLASS
  IS 'The fully qualified name of the Java class that implements the job';

COMMENT ON COLUMN MMP.JOBS.IS_ENABLED
  IS 'Is the job enabled for execution';

COMMENT ON COLUMN MMP.JOBS.STATUS
  IS 'The status of the job';

COMMENT ON COLUMN MMP.JOBS.EXECUTION_ATTEMPTS
  IS 'The number of times the current execution of the job has been attempted';

COMMENT ON COLUMN MMP.JOBS.LOCK_NAME
  IS 'The name of the entity that has locked the job for execution';

COMMENT ON COLUMN MMP.JOBS.LAST_EXECUTED
  IS 'The date and time the job was last executed';

COMMENT ON COLUMN MMP.JOBS.NEXT_EXECUTION
  IS 'The date and time when the job will next be executed';

COMMENT ON COLUMN MMP.JOBS.UPDATED
  IS 'The date and time the job was updated';



CREATE TABLE MMP.JOB_PARAMETERS (
  ID      UUID NOT NULL,
  JOB_ID  UUID NOT NULL,
  NAME    TEXT NOT NULL,
  VALUE   TEXT NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT MMP_JOB_PARAMETERS_JOB_FK FOREIGN KEY (JOB_ID) REFERENCES MMP.JOBS(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_JOB_PARAMETERS_JOB_ID_IX
  ON MMP.JOB_PARAMETERS
  (JOB_ID);

CREATE INDEX MMP_JOB_PARAMETERS_NAME_IX
  ON MMP.JOB_PARAMETERS
  (NAME);

COMMENT ON COLUMN MMP.JOB_PARAMETERS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the job parameter';

COMMENT ON COLUMN MMP.JOB_PARAMETERS.JOB_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the job';

COMMENT ON COLUMN MMP.JOB_PARAMETERS.NAME
  IS 'The name of the job parameter';

COMMENT ON COLUMN MMP.JOB_PARAMETERS.VALUE
  IS 'The value of the job parameter';



CREATE TABLE MMP.CODE_CATEGORIES (
  ID                  UUID NOT NULL,
  CATEGORY_TYPE       INTEGER NOT NULL,
  NAME                TEXT NOT NULL,
  CODE_DATA           BYTEA,
  ENDPOINT            TEXT,
  IS_ENDPOINT_SECURE  BOOLEAN NOT NULL DEFAULT FALSE,
  IS_CACHEABLE        BOOLEAN,
  CACHE_EXPIRY        INTEGER,
  UPDATED             TIMESTAMP,

  PRIMARY KEY (ID)
);

COMMENT ON COLUMN MMP.CODE_CATEGORIES.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the code category';

COMMENT ON COLUMN MMP.CODE_CATEGORIES.CATEGORY_TYPE
  IS 'The type of code category e.g. Local, RemoteHTTPService, RemoteWebService, etc';

COMMENT ON COLUMN MMP.CODE_CATEGORIES.NAME
  IS 'The name of the code category';

COMMENT ON COLUMN MMP.CODE_CATEGORIES.CODE_DATA
  IS 'The custom code data for the code category';

COMMENT ON COLUMN MMP.CODE_CATEGORIES.ENDPOINT
  IS 'The endpoint if this is a remote code category';

COMMENT ON COLUMN MMP.CODE_CATEGORIES.IS_ENDPOINT_SECURE
  IS 'Is the endpoint for the remote code category secure';

COMMENT ON COLUMN MMP.CODE_CATEGORIES.IS_CACHEABLE
  IS 'Is the code data retrieved for the remote code category cacheable';

COMMENT ON COLUMN MMP.CODE_CATEGORIES.CACHE_EXPIRY
  IS 'The time in seconds after which the cached code data for the remote code category will expire';

COMMENT ON COLUMN MMP.CODE_CATEGORIES.UPDATED
  IS 'The date and time the code category was updated';



CREATE TABLE MMP.CODES (
  ID           TEXT NOT NULL,
  CATEGORY_ID  UUID NOT NULL,
  NAME         TEXT NOT NULL,
  VALUE        TEXT NOT NULL,

  PRIMARY KEY (ID, CATEGORY_ID),
  CONSTRAINT MMP_CODES_CODE_CATEGORY_FK FOREIGN KEY (CATEGORY_ID) REFERENCES MMP.CODE_CATEGORIES(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_CODES_CATEGORY_ID_IX
  ON MMP.CODES
  (CATEGORY_ID);

COMMENT ON COLUMN MMP.CODES.ID
  IS 'The ID used to uniquely identify the code';

COMMENT ON COLUMN MMP.CODES.CATEGORY_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the code category the code is associated with';

COMMENT ON COLUMN MMP.CODES.NAME
  IS 'The name of the code';

COMMENT ON COLUMN MMP.CODES.VALUE
  IS 'The value for the code';



CREATE TABLE MMP.CACHED_CODE_CATEGORIES (
  ID            UUID NOT NULL,
  CODE_DATA     BYTEA,
  LAST_UPDATED  TIMESTAMP NOT NULL,
  CACHED        TIMESTAMP NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT MMP_CACHED_CODE_CATEGORIES_CODE_CATEGORY_FK FOREIGN KEY (ID) REFERENCES MMP.CODE_CATEGORIES(ID) ON DELETE CASCADE
);

COMMENT ON COLUMN MMP.CACHED_CODE_CATEGORIES.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the cached code category';

COMMENT ON COLUMN MMP.CACHED_CODE_CATEGORIES.CODE_DATA
  IS 'The custom code data for the cached code category';

COMMENT ON COLUMN MMP.CACHED_CODE_CATEGORIES.LAST_UPDATED
  IS 'The date and time the cached code category was last updated';

COMMENT ON COLUMN MMP.CACHED_CODE_CATEGORIES.CACHED
  IS 'The date and time the code category was cached';



CREATE TABLE MMP.CACHED_CODES (
  ID           TEXT NOT NULL,
  CATEGORY_ID  UUID NOT NULL,
  NAME         TEXT NOT NULL,
  VALUE        TEXT NOT NULL,

  PRIMARY KEY (CATEGORY_ID, ID),
  CONSTRAINT MMP_CACHED_CODES_CACHED_CODE_CATEGORY_FK FOREIGN KEY (CATEGORY_ID) REFERENCES MMP.CACHED_CODE_CATEGORIES(ID) ON DELETE CASCADE
);

CREATE INDEX MMP_CACHED_CODES_CATEGORY_ID_IX
  ON MMP.CACHED_CODES
  (CATEGORY_ID);

COMMENT ON COLUMN MMP.CACHED_CODES.ID
  IS 'The ID used to uniquely identify the code';

COMMENT ON COLUMN MMP.CACHED_CODES.CATEGORY_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the category the code is associated with';

COMMENT ON COLUMN MMP.CACHED_CODES.NAME
  IS 'The name of the code';

COMMENT ON COLUMN MMP.CACHED_CODES.VALUE
  IS 'The value for the code';



CREATE TABLE MMP.REPORT_DEFINITIONS (
  ID        UUID NOT NULL,
  NAME      TEXT NOT NULL,
  TEMPLATE  BYTEA NOT NULL,

  PRIMARY KEY (ID)
);

COMMENT ON COLUMN MMP.REPORT_DEFINITIONS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the report definition';

COMMENT ON COLUMN MMP.REPORT_DEFINITIONS.NAME
  IS 'The name of the report definition';

COMMENT ON COLUMN MMP.REPORT_DEFINITIONS.TEMPLATE
  IS 'The JasperReports template for the report definition';



CREATE TABLE MMP.SMS (
  ID              BIGINT NOT NULL,
  MOBILE_NUMBER   TEXT NOT NULL,
  MESSAGE         TEXT NOT NULL,
  STATUS          INTEGER NOT NULL,
  SEND_ATTEMPTS   INTEGER NOT NULL,
  LOCK_NAME       TEXT,
  LAST_PROCESSED  TIMESTAMP,

  PRIMARY KEY (ID)
);

CREATE INDEX MMP_SMS_MOBILE_NUMBER_IX
  ON MMP.SMS
  (MOBILE_NUMBER);

COMMENT ON COLUMN MMP.SMS.ID
  IS 'The ID used to uniquely identify the SMS';

COMMENT ON COLUMN MMP.SMS.MOBILE_NUMBER
  IS 'The mobile number to send the SMS to';

COMMENT ON COLUMN MMP.SMS.MESSAGE
  IS 'The message to send';

COMMENT ON COLUMN MMP.SMS.STATUS
  IS 'The status of the SMS';

COMMENT ON COLUMN MMP.SMS.SEND_ATTEMPTS
  IS 'The number of times that the sending of the SMS was attempted';

COMMENT ON COLUMN MMP.SMS.LOCK_NAME
  IS 'The name of the entity that has locked the SMS for sending';

COMMENT ON COLUMN MMP.SMS.LAST_PROCESSED
  IS 'The date and time the last attempt was made to send the SMS';



CREATE TABLE SURVEY.SURVEY_TEMPLATES (
  ID           UUID NOT NULL,
  NAME         TEXT NOT NULL,
  DESCRIPTION  TEXT NOT NULL,

	PRIMARY KEY (ID)
);

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATES.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey template';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATES.NAME
  IS 'The name of the survey template.';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATES.DESCRIPTION
  IS 'The description for the survey template.';



CREATE TABLE SURVEY.SURVEY_TEMPLATE_GROUPS (
  ID           UUID NOT NULL,
  TEMPLATE_ID  UUID NOT NULL,
  NAME         TEXT NOT NULL,
  DESCRIPTION  TEXT NOT NULL,
  
	PRIMARY KEY (ID),
	CONSTRAINT  SURVEY_SURVEY_TEMPLATE_GROUPS_SURVEY_TEMPLATE_FK FOREIGN KEY (TEMPLATE_ID) REFERENCES SURVEY.SURVEY_TEMPLATES(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_TEMPLATE_GROUPS_TEMPLATE_ID_IX
  ON SURVEY.SURVEY_TEMPLATE_GROUPS
  (TEMPLATE_ID);

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUPS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey template group';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUPS.TEMPLATE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey template this survey template group is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUPS.NAME
  IS 'The name of the survey template group';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUPS.DESCRIPTION
  IS 'The description for the survey template group';



CREATE TABLE SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS (
  ID                 UUID NOT NULL,
  TEMPLATE_GROUP_ID  UUID NOT NULL,
  NAME               TEXT NOT NULL,
  
	PRIMARY KEY (ID),
	CONSTRAINT  SURVEY_SURVEY_TEMPLATE_GROUP_MEMBERS_SURVEY_TEMPLATE_GROUP_FK FOREIGN KEY (TEMPLATE_GROUP_ID) REFERENCES SURVEY.SURVEY_TEMPLATE_GROUPS(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_TEMPLATE_GROUP_MEMBERS_TEMPLATE_GROUP_ID_IX
  ON SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS
  (TEMPLATE_GROUP_ID);

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS.ID
  IS 'The Universally Unique Identifier (UUID) used  to uniquely identify the survey template group member';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS.TEMPLATE_GROUP_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely  identify the survey template group this survey template group member is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS.NAME
  IS 'The name of the survey template group member';



CREATE TABLE SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (
  ID                 UUID NOT NULL,
  TEMPLATE_ID        UUID NOT NULL,
  NAME               TEXT NOT NULL,
  TEMPLATE_GROUP_ID  UUID NOT NULL,
  RATING_TYPE        INTEGER NOT NULL,
  
	PRIMARY KEY (ID),
	CONSTRAINT  SURVEY_SURVEY_TEMPLATE_GROUP_RATING_ITEMS_SURVEY_TEMPLATE_FK FOREIGN KEY (TEMPLATE_ID) REFERENCES SURVEY.SURVEY_TEMPLATES(ID) ON DELETE CASCADE,
	CONSTRAINT  SURVEY_SURVEY_TEMPLATE_GROUP_RATING_ITEMS_SURVEY_TEMPLATE_GROUP_FK FOREIGN KEY (TEMPLATE_GROUP_ID) REFERENCES SURVEY.SURVEY_TEMPLATE_GROUPS(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_TEMPLATE_GROUP_RATING_ITEMS_TEMPLATE_ID_IX
  ON SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS
  (TEMPLATE_ID);

CREATE INDEX SURVEY_SURVEY_TEMPLATE_GROUP_RATING_ITEMS_TEMPLATE_GROUP_ID_IX
  ON SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS
  (TEMPLATE_GROUP_ID);

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey template group rating item';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS.TEMPLATE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey template this survey template group rating item is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS.NAME
  IS 'The name of the survey template group rating item';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS.TEMPLATE_GROUP_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey template group this survey template group rating item is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS.RATING_TYPE
  IS 'The numeric code giving the type of survey template group rating e.g. 1 = Percentage, 2 = Yes/No/NA, etc';



CREATE TABLE SURVEY.SURVEY_REQUESTS (
  ID           UUID NOT NULL,
  TEMPLATE_ID  UUID NOT NULL,
  
	PRIMARY KEY (ID),
	CONSTRAINT  SURVEY_SURVEY_REQUESTS_SURVEY_TEMPLATE_FK FOREIGN KEY (TEMPLATE_ID) REFERENCES SURVEY.SURVEY_TEMPLATES(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_REQUESTS_TEMPLATE_ID_IX
  ON SURVEY.SURVEY_REQUESTS
  (TEMPLATE_ID);

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.ID
  IS 'The Universally Unique Identifier (UUID) used  to uniquely identify the survey template group member';

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.TEMPLATE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely  identify the survey template group this survey template group member is associated with';



CREATE TABLE SURVEY.SURVEY_RESPONSES (
  ID           UUID NOT NULL,
  TEMPLATE_ID  UUID NOT NULL,
  REQUEST_ID   UUID,
  
	PRIMARY KEY (ID),
	CONSTRAINT  SURVEY_SURVEY_RESPONSES_SURVEY_TEMPLATE_FK FOREIGN KEY (TEMPLATE_ID) REFERENCES SURVEY.SURVEY_TEMPLATES(ID) ON DELETE CASCADE,
	CONSTRAINT  SURVEY_SURVEY_REQUESTS_SURVEY_REQUEST_FK FOREIGN KEY (REQUEST_ID) REFERENCES SURVEY.SURVEY_REQUESTS(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_RESPONSES_TEMPLATE_ID_IX
  ON SURVEY.SURVEY_RESPONSES
  (TEMPLATE_ID);

CREATE INDEX SURVEY_SURVEY_RESPONSES_REQUEST_ID_IX
  ON SURVEY.SURVEY_RESPONSES
  (REQUEST_ID);

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey response';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.TEMPLATE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey template the survey response is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.REQUEST_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey request the survey response is associated with';



CREATE TABLE SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (
  ID                        UUID NOT NULL,
  RESPONSE_ID               UUID NOT NULL,
  TEMPLATE_ITEM_ID          UUID NOT NULL,
  TEMPLATE_GROUP_MEMBER_ID  UUID NOT NULL,
  RATING                    INTEGER NOT NULL,
  
	PRIMARY KEY (ID),
	CONSTRAINT  SURVEY_SURVEY_RESPONSE_GROUP_RATING_ITEMS_SURVEY_RESPONSE_FK FOREIGN KEY (RESPONSE_ID) REFERENCES SURVEY.SURVEY_RESPONSES(ID) ON DELETE CASCADE,
	CONSTRAINT  SURVEY_SURVEY_RESPONSE_GROUP_RATING_ITEMS_SURVEY_TEMPLATE_ITEM_FK FOREIGN KEY (TEMPLATE_ITEM_ID) REFERENCES SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS(ID) ON DELETE CASCADE,
  CONSTRAINT  SURVEY_SURVEY_RESPONSE_GROUP_RATING_ITEMS_SURVEY_TEMPLATE_GROUP_MEMBER_FK FOREIGN KEY (TEMPLATE_GROUP_MEMBER_ID) REFERENCES SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_RESPONSE_GROUP_RATING_ITEMS_RESPONSE_ID_IX
  ON SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS
  (RESPONSE_ID);

CREATE INDEX SURVEY_SURVEY_RESPONSE_GROUP_RATING_ITEMS_TEMPLATE_ITEM_ID_IX
  ON SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS
  (TEMPLATE_ITEM_ID);

CREATE INDEX SURVEY_SURVEY_RESPONSE_GROUP_RATING_ITEMS_TEMPLATE_GROUP_MEMBER_ID_IX
  ON SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS
  (TEMPLATE_GROUP_MEMBER_ID);

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS.ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey response group rating  item';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS.RESPONSE_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey response this survey response group rating item is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS.TEMPLATE_ITEM_ID
  IS 'The Universally Unique Identifier (UUID) used to uniquely identify the survey template group rating item this survey response group rating item is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS.TEMPLATE_GROUP_MEMBER_ID
  IS 'The survey template group member this survey response group rating item is associated with';

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS.RATING
  IS 'The rating for the survey response group rating item e.g. 1=Yes, 0=No and -1=Not Applicable';



-- -------------------------------------------------------------------------------------------------
-- POPULATE TABLES
-- -------------------------------------------------------------------------------------------------
INSERT INTO MMP.ORGANISATIONS (ID, NAME) VALUES
  ('c1685b92-9fe5-453a-995b-89d8c0f29cb5', 'MMP');

INSERT INTO MMP.USER_DIRECTORY_TYPES (ID, NAME, USER_DIRECTORY_CLASS, ADMINISTRATION_CLASS) VALUES
  ('b43fda33-d3b0-4f80-a39a-110b8e530f4f', 'Internal User Directory', 'guru.mmp.application.security.InternalUserDirectory', 'guru.mmp.application.web.template.components.InternalUserDirectoryAdministrationPanel');
INSERT INTO MMP.USER_DIRECTORY_TYPES (ID, NAME, USER_DIRECTORY_CLASS, ADMINISTRATION_CLASS) VALUES
  ('e5741a89-c87b-4406-8a60-2cc0b0a5fa3e', 'LDAP User Directory', 'guru.mmp.application.security.LDAPUserDirectory', 'guru.mmp.application.web.template.components.LDAPUserDirectoryAdministrationPanel');

INSERT INTO MMP.USER_DIRECTORIES (ID, TYPE_ID, NAME, CONFIGURATION) VALUES
  ('4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'b43fda33-d3b0-4f80-a39a-110b8e530f4f', 'Internal User Directory', '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE userDirectory SYSTEM "UserDirectoryConfiguration.dtd"><userDirectory><parameter><name>MaxPasswordAttempts</name><value>5</value></parameter><parameter><name>PasswordExpiryMonths</name><value>12</value></parameter><parameter><name>PasswordHistoryMonths</name><value>24</value></parameter><parameter><name>MaxFilteredUsers</name><value>100</value></parameter></userDirectory>');

INSERT INTO MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (USER_DIRECTORY_ID, ORGANISATION_ID) VALUES
  ('4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'c1685b92-9fe5-453a-995b-89d8c0f29cb5');

INSERT INTO MMP.INTERNAL_USERS (ID, USER_DIRECTORY_ID, USERNAME, PASSWORD, FIRST_NAME, LAST_NAME, PHONE, MOBILE, EMAIL, PASSWORD_ATTEMPTS, PASSWORD_EXPIRY) VALUES
  ('b2bbf431-4af8-4104-b96c-d33b5f66d1e4', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Administrator', 'GVE/3J2k+3KkoF62aRdUjTyQ/5TVQZ4fI2PuqJ3+4d0=', '', '', '', '', '', null, null);

INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('a9e01fa2-f017-46e2-8187-424bf50a4f33', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Administrators', 'Administrators');
INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('758c0a2a-f3a3-4561-bebc-90569291976e', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Organisation Administrators', 'Organisation Administrators');

INSERT INTO MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (INTERNAL_USER_ID, INTERNAL_GROUP_ID) VALUES
  ('b2bbf431-4af8-4104-b96c-d33b5f66d1e4', 'a9e01fa2-f017-46e2-8187-424bf50a4f33');

INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('a9e01fa2-f017-46e2-8187-424bf50a4f33', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Administrators');
INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('758c0a2a-f3a3-4561-bebc-90569291976e', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Organisation Administrators');

INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('2a43152c-d8ae-4b08-8ad9-2448ec5debd5', 'Application.SecureHome', 'Secure Home', 'Secure Home');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('f4e3b387-8cd1-4c56-a2da-fe39a78a56d9', 'Application.Dashboard', 'Dashboard', 'Dashboard');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('2d52b029-920f-4b15-b646-5b9955c188e3', 'Application.OrganisationAdministration', 'Organisation Administration', 'Organisation Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('567d7e55-f3d0-4191-bc4c-12d357900fa3', 'Application.UserAdministration', 'User Administration', 'User Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('ef03f384-24f7-43eb-a29c-f5c5b838698d', 'Application.GroupAdministration', 'Group Administration', 'Group Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('7a54a71e-3680-4d49-b87d-29604a247413', 'Application.UserGroups', 'User Groups', 'User Groups');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('0623bc3f-9a1b-4f19-8438-236660d789c5', 'Application.CodeCategoryAdministration', 'Code Category Administration', 'Code Category Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('4e6bc7c4-ee29-4cd7-b4d7-3be42db73dd6', 'Application.CodeAdministration', 'Code Administration', 'Code Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('029b9a06-0241-4a44-a234-5c489f2017ba', 'Application.ResetUserPassword', 'Reset User Password', 'Reset User Password');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('9105fb6d-1629-4014-bf4c-1990a92db276', 'Application.SecurityAdministration', 'Security Administration', 'Security Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('b233ed4a-b30f-4356-a5d3-1c660aa69f00', 'Application.ConfigurationAdministration', 'Configuration Administration', 'Configuration Administration');

INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('3a17959c-5dfc-43a2-9587-48a1eb95a22a', 'Application.ReportDefinitionAdministration', 'Report Definition Administration', 'Report Definition Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('539fceb8-da82-4170-ab1a-ae6b04001c03', 'Application.ViewReport', 'View Report', 'View Report');

INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('4d60aed6-2d4b-4a91-a178-ac06d4b1769a', 'Application.SchedulerAdministration', 'Scheduler Administration', 'Scheduler Administration');

INSERT INTO MMP.ROLES (ID, NAME, DESCRIPTION) VALUES
  ('100fafb4-783a-4204-a22d-9e27335dc2ea', 'Administrator', 'Administrator');
INSERT INTO MMP.ROLES (ID, NAME, DESCRIPTION) VALUES
  ('44ff0ad2-fbe1-489f-86c9-cef7f82acf35', 'Organisation Administrator', 'Organisation Administrator');

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2a43152c-d8ae-4b08-8ad9-2448ec5debd5', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.SecureHome
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('f4e3b387-8cd1-4c56-a2da-fe39a78a56d9', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.Dashboard
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2d52b029-920f-4b15-b646-5b9955c188e3', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.OrganisationAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('567d7e55-f3d0-4191-bc4c-12d357900fa3', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.UserAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('ef03f384-24f7-43eb-a29c-f5c5b838698d', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.GroupAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('7a54a71e-3680-4d49-b87d-29604a247413', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.UserGroups
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('0623bc3f-9a1b-4f19-8438-236660d789c5', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.CodeCategoryAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('4e6bc7c4-ee29-4cd7-b4d7-3be42db73dd6', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.CodeAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('029b9a06-0241-4a44-a234-5c489f2017ba', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.ResetUserPassword
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('9105fb6d-1629-4014-bf4c-1990a92db276', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.SecurityAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('b233ed4a-b30f-4356-a5d3-1c660aa69f00', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.ConfigurationAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('3a17959c-5dfc-43a2-9587-48a1eb95a22a', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.ReportDefinitionAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('539fceb8-da82-4170-ab1a-ae6b04001c03', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.ViewReport
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('4d60aed6-2d4b-4a91-a178-ac06d4b1769a', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Application.SchedulerAdministration

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2a43152c-d8ae-4b08-8ad9-2448ec5debd5', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.SecureHome
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('f4e3b387-8cd1-4c56-a2da-fe39a78a56d9', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.Dashboard
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('567d7e55-f3d0-4191-bc4c-12d357900fa3', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.UserAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('7a54a71e-3680-4d49-b87d-29604a247413', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.UserGroups
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('029b9a06-0241-4a44-a234-5c489f2017ba', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.ResetUserPassword
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('539fceb8-da82-4170-ab1a-ae6b04001c03', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.ViewReport

INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('100fafb4-783a-4204-a22d-9e27335dc2ea', 'a9e01fa2-f017-46e2-8187-424bf50a4f33');
INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('44ff0ad2-fbe1-489f-86c9-cef7f82acf35', '758c0a2a-f3a3-4561-bebc-90569291976e');



INSERT INTO SURVEY.SURVEY_TEMPLATES (ID, NAME, DESCRIPTION) VALUES
  ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'CTO ELT Values Survey - November 2016', '');

INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUPS (ID, TEMPLATE_ID, NAME, DESCRIPTION) VALUES
  ('98886698-8ba8-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'CTO ELT', '');

INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS (ID, TEMPLATE_GROUP_ID, NAME) VALUES
  ('dd6c1390-8ba8-11e6-ae22-56b6b6499611', '98886698-8ba8-11e6-ae22-56b6b6499611', 'Dan');
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS (ID, TEMPLATE_GROUP_ID, NAME) VALUES
  ('dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', '98886698-8ba8-11e6-ae22-56b6b6499611', 'Marcus');

INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c34543f0-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Accountability', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c345462a-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Competence', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c34549f4-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Courage', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c3454b7a-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Fairness', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c3454c6a-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Integrity', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c3454d3c-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Openness', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c3454e04-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Positive Attitude', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c3454ec2-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Teamwork', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c3454f8a-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Making a Difference', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);
INSERT INTO SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS (ID, TEMPLATE_ID, NAME, TEMPLATE_GROUP_ID, RATING_TYPE) VALUES
  ('c345523c-8ba9-11e6-ae22-56b6b6499611', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 'Trust', '98886698-8ba8-11e6-ae22-56b6b6499611', 2);

INSERT INTO SURVEY.SURVEY_REQUESTS (ID, TEMPLATE_ID) VALUES
  ('0607b63e-8bcb-11e6-a865-0401beb96201', '706fb4a4-8ba8-11e6-ae22-56b6b6499611');
  
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, TEMPLATE_ID, REQUEST_ID) VALUES
  ('39349e3c-8bcb-11e6-bc9f-0401beb96201', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', '0607b63e-8bcb-11e6-a865-0401beb96201');


-- Accountability
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('3208b098-8bcc-11e6-8ddb-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c34543f0-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('bdeee456-8bcc-11e6-8ddb-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c34543f0-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Competence
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('e74510fe-8bcd-11e6-8ddb-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c345462a-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('eca84aac-8bcd-11e6-bc9f-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c345462a-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Courage
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('f08d43d4-8bcd-11e6-910e-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c34549f4-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('f5365bb4-8bcd-11e6-bc9f-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c34549f4-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Fairness
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('ffaeb78a-8bcd-11e6-8ddb-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454b7a-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('03e0ebd4-8bce-11e6-bc9f-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454b7a-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Integrity
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('0712915e-8bce-11e6-b9cf-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454c6a-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('0a38fa12-8bce-11e6-910e-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454c6a-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Openness
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('0db1b74c-8bce-11e6-bc9f-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454d3c-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('12b0dd04-8bce-11e6-a865-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454d3c-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Positive Attitude
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('169448a2-8bce-11e6-910e-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454e04-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('1b14feb2-8bce-11e6-8ddb-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454e04-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Teamwork
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('27803d56-8bce-11e6-910e-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454ec2-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('2b2232b6-8bce-11e6-8ddb-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454ec2-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Making a Difference
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('2e198442-8bce-11e6-a865-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454f8a-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('30d76884-8bce-11e6-8ddb-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c3454f8a-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);

-- Trust
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('348e2f94-8bce-11e6-8ddb-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c345523c-8ba9-11e6-ae22-56b6b6499611', 'dd6c1390-8ba8-11e6-ae22-56b6b6499611', 1);
INSERT INTO SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS (ID, RESPONSE_ID, TEMPLATE_ITEM_ID, TEMPLATE_GROUP_MEMBER_ID, RATING) VALUES
  ('3760b9bc-8bce-11e6-b9cf-0401beb96201', '39349e3c-8bcb-11e6-bc9f-0401beb96201', 'c345523c-8ba9-11e6-ae22-56b6b6499611', 'dd6c0ea4-8ba8-11e6-ae22-56b6b6499611', 1);




-- -------------------------------------------------------------------------------------------------
-- SET PERMISSIONS
-- -------------------------------------------------------------------------------------------------
GRANT ALL ON SCHEMA MMP TO survey;
GRANT ALL ON SCHEMA SURVEY TO survey;

GRANT ALL ON TABLE MMP.IDGENERATOR TO survey;
GRANT ALL ON TABLE MMP.CONFIG TO survey;
GRANT ALL ON TABLE MMP.REGISTRY TO survey;
GRANT ALL ON TABLE MMP.SERVICE_REGISTRY TO survey;
GRANT ALL ON TABLE MMP.ORGANISATIONS TO survey;
GRANT ALL ON TABLE MMP.USER_DIRECTORY_TYPES TO survey;
GRANT ALL ON TABLE MMP.USER_DIRECTORIES TO survey;
GRANT ALL ON TABLE MMP.USER_DIRECTORY_TO_ORGANISATION_MAP TO survey;
GRANT ALL ON TABLE MMP.INTERNAL_USERS TO survey;
GRANT ALL ON TABLE MMP.INTERNAL_USERS_PASSWORD_HISTORY TO survey;
GRANT ALL ON TABLE MMP.INTERNAL_GROUPS TO survey;
GRANT ALL ON TABLE MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP TO survey;
GRANT ALL ON TABLE MMP.GROUPS TO survey;
GRANT ALL ON TABLE MMP.FUNCTIONS TO survey;
GRANT ALL ON TABLE MMP.ROLES TO survey;
GRANT ALL ON TABLE MMP.FUNCTION_TO_ROLE_MAP TO survey;
GRANT ALL ON TABLE MMP.ROLE_TO_GROUP_MAP TO survey;
GRANT ALL ON TABLE MMP.JOBS TO survey;
GRANT ALL ON TABLE MMP.JOB_PARAMETERS TO survey;
GRANT ALL ON TABLE MMP.CODE_CATEGORIES TO survey;
GRANT ALL ON TABLE MMP.CODES TO survey;
GRANT ALL ON TABLE MMP.CACHED_CODE_CATEGORIES TO survey;
GRANT ALL ON TABLE MMP.CACHED_CODES TO survey;
GRANT ALL ON TABLE MMP.REPORT_DEFINITIONS TO survey;
GRANT ALL ON TABLE MMP.SMS TO survey;

GRANT ALL ON TABLE SURVEY.SURVEY_TEMPLATES TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_TEMPLATE_GROUPS TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_TEMPLATE_GROUP_MEMBERS TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_TEMPLATE_GROUP_RATING_ITEMS TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_REQUESTS TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_RESPONSES TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_RESPONSE_GROUP_RATING_ITEMS TO survey;




