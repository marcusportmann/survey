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
--    CentOS (as root): su postgres -c 'psql -d surveydb -f SurveyPostgres.sql'
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
DROP TABLE IF EXISTS SURVEY.SURVEY_AUDIENCES CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_RESPONSES CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_REQUESTS CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_INSTANCES CASCADE;
DROP TABLE IF EXISTS SURVEY.SURVEY_DEFINITIONS CASCADE;

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



CREATE TABLE SURVEY.SURVEY_DEFINITIONS (
  ID               UUID NOT NULL,
  VERSION          INTEGER NOT NULL,
  ORGANISATION_ID  UUID NOT NULL,
  NAME             TEXT NOT NULL,
  DESCRIPTION      TEXT NOT NULL,
  DATA             JSONB NOT NULL,

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
  FIRST_NAME          TEXT NOT NULL,
  LAST_NAME           TEXT NOT NULL,
  EMAIL               TEXT NOT NULL,
  SENT                TIMESTAMP NOT NULL,

  PRIMARY KEY (ID),
  CONSTRAINT  SURVEY_SURVEY_REQUESTS_SURVEY_INSTANCE_FK FOREIGN KEY (SURVEY_INSTANCE_ID) REFERENCES SURVEY.SURVEY_INSTANCES(ID) ON DELETE CASCADE
);

CREATE INDEX SURVEY_SURVEY_REQUESTS_SURVEY_INSTANCE_ID_IX
  ON SURVEY.SURVEY_REQUESTS
  (SURVEY_INSTANCE_ID);

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

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.SENT
  IS 'The date and time the request to complete the survey was last sent';



CREATE TABLE SURVEY.SURVEY_RESPONSES (
  ID                  UUID NOT NULL,
  SURVEY_INSTANCE_ID  UUID NOT NULL,
  SURVEY_REQUEST_ID   UUID,
  RECEIVED            TIMESTAMP NOT NULL,
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

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.RECEIVED
  IS 'The date and time the survey response was received';

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
  ('c1685b92-9fe5-453a-995b-89d8c0f29cb5', 'MMP');
INSERT INTO MMP.ORGANISATIONS (ID, NAME) VALUES
  ('d077425e-c75f-4dd8-9d62-81f2d26b8a62', 'BAGL - Africa Technology - CTO');

INSERT INTO MMP.USER_DIRECTORY_TYPES (ID, NAME, USER_DIRECTORY_CLASS, ADMINISTRATION_CLASS) VALUES
  ('b43fda33-d3b0-4f80-a39a-110b8e530f4f', 'Internal User Directory', 'guru.mmp.application.security.InternalUserDirectory', 'guru.mmp.application.web.template.components.InternalUserDirectoryAdministrationPanel');
INSERT INTO MMP.USER_DIRECTORY_TYPES (ID, NAME, USER_DIRECTORY_CLASS, ADMINISTRATION_CLASS) VALUES
  ('e5741a89-c87b-4406-8a60-2cc0b0a5fa3e', 'LDAP User Directory', 'guru.mmp.application.security.LDAPUserDirectory', 'guru.mmp.application.web.template.components.LDAPUserDirectoryAdministrationPanel');

INSERT INTO MMP.USER_DIRECTORIES (ID, TYPE_ID, NAME, CONFIGURATION) VALUES
  ('4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'b43fda33-d3b0-4f80-a39a-110b8e530f4f', 'Internal User Directory', '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE userDirectory SYSTEM "UserDirectoryConfiguration.dtd"><userDirectory><parameter><name>MaxPasswordAttempts</name><value>5</value></parameter><parameter><name>PasswordExpiryMonths</name><value>12</value></parameter><parameter><name>PasswordHistoryMonths</name><value>24</value></parameter><parameter><name>MaxFilteredUsers</name><value>100</value></parameter></userDirectory>');
INSERT INTO MMP.USER_DIRECTORIES (ID, TYPE_ID, NAME, CONFIGURATION) VALUES
  ('b229d620-bfd7-4a7b-926c-5041da432ae3', 'b43fda33-d3b0-4f80-a39a-110b8e530f4f', 'BAGL - Africa Technology - CTO', '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE userDirectory SYSTEM "UserDirectoryConfiguration.dtd"><userDirectory><parameter><name>MaxPasswordAttempts</name><value>5</value></parameter><parameter><name>PasswordExpiryMonths</name><value>12</value></parameter><parameter><name>PasswordHistoryMonths</name><value>24</value></parameter><parameter><name>MaxFilteredUsers</name><value>100</value></parameter></userDirectory>');

INSERT INTO MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (USER_DIRECTORY_ID, ORGANISATION_ID) VALUES
  ('4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'c1685b92-9fe5-453a-995b-89d8c0f29cb5');
INSERT INTO MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (USER_DIRECTORY_ID, ORGANISATION_ID) VALUES
  ('4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62');
INSERT INTO MMP.USER_DIRECTORY_TO_ORGANISATION_MAP (USER_DIRECTORY_ID, ORGANISATION_ID) VALUES
  ('b229d620-bfd7-4a7b-926c-5041da432ae3', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62');

INSERT INTO MMP.INTERNAL_USERS (ID, USER_DIRECTORY_ID, USERNAME, PASSWORD, FIRST_NAME, LAST_NAME, PHONE, MOBILE, EMAIL, PASSWORD_ATTEMPTS, PASSWORD_EXPIRY) VALUES
  ('b2bbf431-4af8-4104-b96c-d33b5f66d1e4', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Administrator', 'GVE/3J2k+3KkoF62aRdUjTyQ/5TVQZ4fI2PuqJ3+4d0=', '', '', '', '', '', null, null);

INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('a9e01fa2-f017-46e2-8187-424bf50a4f33', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Administrators', 'Administrators');
INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('758c0a2a-f3a3-4561-bebc-90569291976e', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Organisation Administrators', 'Organisation Administrators');
INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Organisation Administrators', 'Organisation Administrators');
INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('74bd122c-74d9-4e40-95b8-0550f54a0267', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Survey Administrators', 'Survey Administrators');
INSERT INTO MMP.INTERNAL_GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME, DESCRIPTION) VALUES
  ('82b72c08-6544-41bd-93dd-f82c74477376', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Survey Viewers', 'Survey Viewers');

INSERT INTO MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (INTERNAL_USER_ID, INTERNAL_GROUP_ID) VALUES
  ('b2bbf431-4af8-4104-b96c-d33b5f66d1e4', 'a9e01fa2-f017-46e2-8187-424bf50a4f33');

INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('a9e01fa2-f017-46e2-8187-424bf50a4f33', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Administrators');
INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('758c0a2a-f3a3-4561-bebc-90569291976e', '4ef18395-423a-4df6-b7d7-6bcdd85956e4', 'Organisation Administrators');
INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Organisation Administrators');
INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('74bd122c-74d9-4e40-95b8-0550f54a0267', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Survey Administrators');
INSERT INTO MMP.GROUPS (ID, USER_DIRECTORY_ID, GROUPNAME) VALUES ('82b72c08-6544-41bd-93dd-f82c74477376', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'Survey Viewers');


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
  
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('20725a56-7103-4056-8c74-62f50239ccb7', 'Survey.SurveyAudienceAdministration', 'Survey Audience Administration', 'Survey Audience Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('381a0942-feb8-489f-b9f8-d65f90a7eab7', 'Survey.SurveyAdministration', 'Survey Administration', 'Survey Administration');
INSERT INTO MMP.FUNCTIONS (ID, CODE, NAME, DESCRIPTION) VALUES
  ('2d25184e-39e5-451b-b4c9-62fe109a71e2', 'Survey.ViewSurveyResponse', 'View Survey Response', 'View Survey Response');
  
  

INSERT INTO MMP.ROLES (ID, NAME, DESCRIPTION) VALUES
  ('100fafb4-783a-4204-a22d-9e27335dc2ea', 'Administrator', 'Administrator');
INSERT INTO MMP.ROLES (ID, NAME, DESCRIPTION) VALUES
  ('44ff0ad2-fbe1-489f-86c9-cef7f82acf35', 'Organisation Administrator', 'Organisation Administrator');
INSERT INTO MMP.ROLES (ID, NAME, DESCRIPTION) VALUES
  ('313bf6a4-b58a-4979-a2e3-50ee74b84b32', 'Survey Administrator', 'Survey Administrator');
INSERT INTO MMP.ROLES (ID, NAME, DESCRIPTION) VALUES
  ('fd140749-2f7b-4e25-b5de-c10bc878f355', 'Survey Viewer', 'Survey Viewer');

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
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('20725a56-7103-4056-8c74-62f50239ccb7', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Survey.SurveyAudienceAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('381a0942-feb8-489f-b9f8-d65f90a7eab7', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Survey.SurveyAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2d25184e-39e5-451b-b4c9-62fe109a71e2', '100fafb4-783a-4204-a22d-9e27335dc2ea'); -- Survey.ViewSurveyResponse

INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('2a43152c-d8ae-4b08-8ad9-2448ec5debd5', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.SecureHome
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('f4e3b387-8cd1-4c56-a2da-fe39a78a56d9', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.Dashboard
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('567d7e55-f3d0-4191-bc4c-12d357900fa3', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.UserAdministration
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('7a54a71e-3680-4d49-b87d-29604a247413', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.UserGroups
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('029b9a06-0241-4a44-a234-5c489f2017ba', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.ResetUserPassword
INSERT INTO MMP.FUNCTION_TO_ROLE_MAP (FUNCTION_ID, ROLE_ID) VALUES ('539fceb8-da82-4170-ab1a-ae6b04001c03', '44ff0ad2-fbe1-489f-86c9-cef7f82acf35'); -- Application.ViewReport
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



INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('100fafb4-783a-4204-a22d-9e27335dc2ea', 'a9e01fa2-f017-46e2-8187-424bf50a4f33');
INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('44ff0ad2-fbe1-489f-86c9-cef7f82acf35', '758c0a2a-f3a3-4561-bebc-90569291976e');
INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('44ff0ad2-fbe1-489f-86c9-cef7f82acf35', '5cf2f1c1-aa73-48e4-be83-be3d7ca5dcc6');
INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('313bf6a4-b58a-4979-a2e3-50ee74b84b32', '74bd122c-74d9-4e40-95b8-0550f54a0267');
INSERT INTO MMP.ROLE_TO_GROUP_MAP (ROLE_ID, GROUP_ID) VALUES ('fd140749-2f7b-4e25-b5de-c10bc878f355', '82b72c08-6544-41bd-93dd-f82c74477376'); 




INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, DATA) VALUES
  ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'c1685b92-9fe5-453a-995b-89d8c0f29cb5', 'CTO ELT Values Survey', '', '{"id":"706fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"organisationId":"c1685b92-9fe5-453a-995b-89d8c0f29cb5","name":"CTO ELT Values Survey","description":"CTO ELT Values Survey","sectionDefinitions":[],"groupDefinitions":[{"id":"29fd11d8-a89c-42a7-afc4-4236f0af832c","name":"CTO ELT","description":"CTO ELT","groupMemberDefinitions":[{"id":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","name":"CTO ELT"},{"id":"5f54bb9f-716a-452f-bf65-afa97381a50c","name":"Peter"},{"id":"01c40693-27de-4445-a043-93bc3b814359","name":"Adriaan"},{"id":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","name":"Alapan"},{"id":"29a95962-6e01-443e-9f69-3502b2fd69aa","name":"Dan"},{"id":"eb85edd3-baae-44c3-b107-e37a835d2093","name":"Daryl"},{"id":"2a4ea3ad-142c-404b-8077-7b14545715ef","name":"David"},{"id":"46a93633-efb3-4029-a549-b0b661f95253","name":"Francois"},{"id":"64a15e88-b04d-459e-9dba-a5f8b174f85e","name":"James"},{"id":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","name":"Kersh"},{"id":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","name":"Kevin"},{"id":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","name":"Linde-Marie"},{"id":"81485cff-e306-433e-b420-1c8b248dd804","name":"Manoj"},{"id":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","name":"Marcus"},{"id":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","name":"Mercia"},{"id":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","name":"Nicole"},{"id":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","name":"Lawrence"},{"id":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","name":"Richard"},{"id":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","name":"Sandra"},{"id":"962e40d5-06af-4743-882a-02cea33666c3","name":"Tendai"},{"id":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","name":"Debbie"}]}],"groupRatingItemDefinitions":[{"id":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","name":"Accountability","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","name":"Competence","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"b22716c0-faed-4a99-914f-cd291d994a62","name":"Courage","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","name":"Fairness","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"878fcaa2-f532-485a-bf09-e1815223ea86","name":"Integrity","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","name":"Openness","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","name":"Positive Attitude","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"09a57f34-0227-49c6-a80f-e2f73643fe26","name":"Teamwork","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"230e38ec-cc67-456c-a6d1-1d09fe679800","name":"Making a difference","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2},{"id":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","name":"Trust","groupDefinitionId":"29fd11d8-a89c-42a7-afc4-4236f0af832c","ratingType":2}]}');

INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME) VALUES
  ('b222aa15-715f-4752-923d-8f33ee8a1736', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'CTO ELT Values Survey - September 2016');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, SENT) VALUES
  ('54a751f6-0f32-48bd-8c6c-665e3ac1906b', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Marcus', 'Portmann', 'marcus@mmp.guru', NOW());
  
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RECEIVED, DATA) VALUES
  ('18f3fcc1-06b2-4dc4-90ea-7a8904009488', 'b222aa15-715f-4752-923d-8f33ee8a1736', '54a751f6-0f32-48bd-8c6c-665e3ac1906b', NOW(), '{"id":"18f3fcc1-06b2-4dc4-90ea-7a8904009488","groupRatingItemResponses":[{"id":"6b1f4517-c329-4620-9735-e69a5d7e16f6","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"f3ff7e23-08c1-4529-9383-c1700646f6e1","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"204b5201-ab05-4d9d-b5c3-edad2b89cf62","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"8e7e096c-de71-4235-a9b3-bb309676c645","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"a505f28a-765c-4dea-a812-82a5cd1a6f5a","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"8dec6750-1709-419f-a3dc-555509f21136","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"1df9804f-acb1-4309-bd13-d082993aa68f","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"6a6f1cb6-2e4f-4dd7-97f4-e30eea452d81","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"6853f9fa-2c1e-4378-9e04-0cd25034f222","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"71318c61-e205-4069-9bcf-a9d95026eb93","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"d3025c18-2767-4a77-8fee-c3ec9b4fbcc8","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"edc43747-a398-4320-a7eb-988169d44877","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"25a7bd40-a884-444d-a2cf-9e5f6a5bfdef","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"5665d60a-ba90-4a32-8da3-188daea8c410","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"8cd220ec-83b0-4100-a71b-bbc9bcf170f7","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"fa980bef-3851-4a36-8fb3-3a6e58ee6fdb","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"827a1d65-7770-4846-96ad-975d1a7a84a7","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"60ddb02a-74aa-4c3d-9fc9-956834c8220d","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"1546f5b7-3412-4e99-ad9c-cc57acede724","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"251753fd-981b-42e8-b2aa-806955dc1991","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"8da3c27d-00e6-4c32-86b3-cb344123dc79","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"ed708e34-646d-48c0-bfa2-59218041b320","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"d76693e8-4cfa-4a4d-8533-d2a7f28fe974","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"a2d11fe9-3e8c-4f31-b087-ce39a9ca7678","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"c2f441c2-fe62-4b8e-a957-5859faea3601","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"1959e443-f79b-40df-b7c9-4f934c0076eb","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"5ba40807-6b66-4939-bfd1-d37c054b3aa8","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"96c3f685-01e6-45cf-9bcf-23744c752622","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"2e356b72-f236-4d89-b7c2-1b5013db1450","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"b26e791f-6788-4752-8483-0a812a186b83","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"451364ca-765c-4bcc-8530-9b543f7c8fb8","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"d0a01af5-9cfe-461e-9c0f-7bab1042dc24","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"1508d575-0ed4-4311-8e1d-c4599d99d39a","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"9d39f633-3003-4988-b210-0405f538d366","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"acaf13af-7c2c-4121-9b49-d7c33b98e37d","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"ce102321-4361-45b5-9067-412b42e1362d","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"e47728a7-37ef-4b8c-98c7-8e5705d39e36","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"1582f166-5d4d-49fd-8006-4f07d051d477","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"4f68e8ff-789f-4838-ad24-84db87bf2788","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"1128917e-ad35-4bac-9a60-7088503f7b94","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"19bcb21d-35c0-440f-870a-5eae55cdba91","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"05e67bb6-e658-410c-8f4d-bb570d7686de","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"0af02b16-bd8e-4c22-a720-1b590b488e42","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"88e9a955-d091-47bd-9f6e-51966d1e952b","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"f1e768fc-2bd1-4852-a8fa-8ba9c2080f0b","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"0447bc1e-cfec-4485-9d2b-3dae7c3aa0f2","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"9bd5f145-b689-48f4-8e3f-0f95806e8a18","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"bd1fa84b-34df-4c20-b6ed-24f45a58cdea","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"985a7e0d-5e08-4f3f-a464-929ec839b671","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"29a40b8b-3b04-47a5-a11a-70ba64e3aad6","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"a063918b-3807-4b27-84c6-4de524ef2436","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"4ddc2689-d1ae-4726-b66a-436d7076a880","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"a25c80a0-62f2-41cf-9196-9e2b5205874a","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"951818a0-e39b-444b-9924-fa498a1e67b5","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"c1f8f971-21a6-4ec5-957a-71bbeb55774a","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"f682f09f-d81e-4590-995b-c018c1faec90","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"b8121d23-fcc3-48f8-a6b3-1651a5c4fa4a","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"5ada4d80-7d8a-461b-876e-7672dc31f1e9","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"6aa10691-27ac-48ab-9828-51ba5b2a9c3c","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"090bbbe9-bd55-4fa9-ba1b-5a5fbc6713b6","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"bbf33aea-0ba3-4e66-ad58-39dbf23f95fb","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"7d2f21a8-9853-4489-ad7b-ce1eaedbcb8e","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"7f111dff-9317-448b-a7d0-9e3765956dce","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"cc2d4f5a-24bd-4263-a7c7-6f3b366eacb5","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"507f22fb-4449-43a6-9c9e-9ba8b7d93325","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"b5c516aa-6c78-47a2-a7d6-7d01e695cdd6","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"f90f5570-0d4c-471c-8518-0b007c72f47e","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"175d41a2-0099-414c-9c60-6269e4ab8f7f","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"fe886ddf-f045-4814-b80d-8a5d2c532350","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"8657230c-1694-4f4c-b3ad-d6b74a261bfe","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"745fb329-b7b0-45a7-806b-1d838c337145","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"add6920b-926a-4473-ae29-7f4c598742cb","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"e0007e88-d933-46a1-a13d-7e1a2c748bfe","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"9d635f77-31d6-4fef-b49b-8deb01d64d2d","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"e7953079-33f9-4a19-8540-fcf22567823d","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"35ec6a38-e276-4873-8714-f4804f990297","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"a919c9a4-58d3-4f7d-8ee1-6e612d2499cc","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"439afbc4-4417-46a1-b7e8-e044c9055960","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"f10499fb-b532-4f92-95c6-070a7c3dbe55","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"7a412bcf-7327-4742-a226-1bccf9acedcb","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"1abbdc89-9422-434c-88d9-93b859cbba9c","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"2ee01c62-638e-4cb9-a287-fac37939225f","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"335da0f2-e5fe-428f-9495-517d7a60a6b9","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"25389a81-6572-4aa7-9ade-32a73d998fc1","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"789dc815-35ac-4714-923e-cbfd6a5603ce","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"9b0ae3cf-85d1-4730-9033-c71863d08746","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"bd2109ed-6693-4ec6-86f7-c5e93148c70d","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"70167288-c2f7-44e4-aa0d-06a1a1b5f707","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"7e163fdf-d718-4273-9b0f-c6f98e792752","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"45718b98-96ad-4d6f-a09a-6c5c29e871e5","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"e6f952d7-001f-4b55-af77-486f2cb843e7","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"cbfee017-705a-4723-b2c6-7fa4de1bab60","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"12158b38-e3ab-4564-823d-2c0fffdabe1a","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"fcd6cc0d-9d3b-413d-89a6-76564f92e55f","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"961f49ac-3011-479f-84a9-9d97c96569ba","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"860ed4af-ff0c-4524-88f3-0310685d2f03","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"42b2d958-6527-460e-8133-4b3023f0576f","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"cb1e0615-2881-49a1-bf43-64eb7603a553","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"61a691cf-ebff-4dca-921d-b3c76f4e123e","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"e01dc550-e31a-4fda-8a18-09486aa32051","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"2e3f048e-a403-4d08-98f8-b2025f14a4fd","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"cf1d0d37-adbd-4c08-978c-88c3b9b1c9c4","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"baa41947-e553-4b2a-95f8-abe23441d2bd","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"7bc1a54b-dc53-49e7-bb9e-2fadd9392056","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"c12bbbb1-4a75-415e-85e3-5cd417459685","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"96fc694b-b3be-48dd-8c00-10674440b4d1","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"d4be7695-e2e8-4e99-af7f-d4d7f057c87f","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"406804a3-ea1a-476f-91d2-b0db18272278","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"4436a481-fa7b-4805-b012-a737f3ebdbf1","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"bb8c4649-4db8-4419-af05-d8d7b88d6bcd","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"e4f6efa5-4700-4854-adc3-9b31c68e1524","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"506e9ddf-c26a-4506-8416-9822ee2bb102","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"34cd9501-6ac6-4f30-8a3c-ffd0df2d1061","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"d3b20fec-4402-4edc-b947-c6208d067bc9","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"ece95af1-52e9-4b5f-8512-40f394736a0d","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"474f5f6b-777d-43db-9156-214e2b49a6ee","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"f0d764a9-5437-4a94-a4f6-f673960b3ec3","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"64b4d571-8a51-4a8e-8db7-6b6e921cde13","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"645a62bf-0938-478e-b8d7-d344bcc292eb","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"b8a2187e-329d-4a68-9543-d97b0af273fd","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"ea6ae3d7-c7e9-4ffd-8d72-9a6b5e6811d5","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"03518bea-f29f-4be2-86ad-c1d272a94264","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"c225442e-8620-498c-91e4-4d81124feb4b","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"985d356c-6fc1-4afb-b571-b295e3c5cda6","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"270daf7b-22fb-4c8d-b0aa-56cb4b12b67f","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"199a7239-0f12-49b2-9399-06bf409dd5d4","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"4d113b5f-069b-44d3-801b-382934b99c9c","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"fa85533f-31a7-4b3e-b55c-f6c1aa7a96cf","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"d782bbfc-dd8f-45f1-83b8-f92736944b72","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"3a7a23d8-c07d-406c-9ba6-714e85803a3e","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"a3626137-4fdf-49d6-b4bd-eda5dc0a7924","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"142939e5-ebaf-4076-a6e1-3040fb388f26","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"d8e6c255-6244-429a-843f-15449bd05088","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"171e270d-ed7e-411b-a632-620f85f43c57","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"043558cf-ca9d-4246-8187-5b82aebf226a","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"dae2c4cf-cdee-4c48-ad7c-aa75ebcf9337","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"fdafbb0f-4acc-4a20-9b30-68dbf4d22355","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"9a3d04ca-3efc-4b08-83ff-167e6212ec3c","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"738e67e2-4d19-4d5a-9eb5-5cb09f801f1e","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"c5c6e1cc-1ed0-4efe-83a9-e813d57e8350","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"6b3a05d1-69ed-454f-b9a2-c76a9f772209","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"c23a3574-6672-4023-9f48-3502216c26bc","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"20a289df-2c8d-4713-a319-82c35acd354c","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"59bb8ee2-8956-4f8a-90b4-5694fd8b0292","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"2b32887f-5902-4072-b9cf-bb71a3711e98","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"cf2d28d5-0e40-44ad-aeb8-5a298565772d","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"1fbab56e-16cf-47a2-9418-fd54e04857eb","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"b7e18848-2ce1-4eb3-ab4f-e3565f223061","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"83c74bd7-a3f6-4edd-9f56-03886906d5e1","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"c6c5d554-73c8-4c85-ac26-0542135fabca","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"cc4d7b0d-d9ca-42ef-926b-728de3810754","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"86a738a9-e2b7-441d-bc2f-85ec577ca6e5","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"e87a7f92-d98b-4721-9853-45089f53e502","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"5fb9a61b-f4f5-46fb-a778-d70a799f0890","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"5b98fdf1-a6b0-45bf-9149-041b5400ac8e","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"ca7e1976-be64-488e-9bcd-c731ce3ed967","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"5e509e57-1cf1-42a2-b607-aff010611557","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"4daa40bb-2fce-4dfe-a1a2-2662f5388cfa","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"bc625e84-fc18-4b52-b6fc-a6d872cf411a","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"04d31131-6d04-4ab8-ae53-edacabbd8d4e","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"71cb6b7a-67a0-4b27-936f-94d75944d380","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"1fcd0612-ff68-4488-b7a0-583f926111ff","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"dfa00bf0-2240-4999-b551-dd9171f82714","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"7696fe76-a5ea-4e7f-893f-8cc556e2dbd8","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"f3e04524-881c-4152-89f5-95e532ac2989","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"47cdcaca-3596-4df5-9418-a153ff03be6a","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"976eb873-e826-47e0-a206-50c9e976897f","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"95c642ef-da4f-423a-8ab7-2356b23d60b9","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"f50bb3d8-7122-4223-a3d6-588dab244032","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"3c0fe46f-51bf-4e51-a304-94695e8f5886","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"9e0596bb-a00e-48a6-81b5-e802b6da6960","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"5ad3f2d6-1234-40b8-98e6-a5ac56711305","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"e97486d4-1dc1-4b34-bf76-febdcec91f99","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"0a298447-c4e1-4974-be5b-7998791c83fa","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"75af8119-f688-4b89-addd-eb2874e847bf","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"9228f072-d4af-4516-a9b4-6f788443f5a2","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"4e56b56e-905a-4feb-8b53-7a21f8d70c33","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"42921b23-7aad-4d1e-ab6e-181c94886e88","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"366fafe4-0c31-4ee7-82a1-021f9ec6f7bc","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"c671859b-f34d-4387-b4ba-7a6828434428","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"bdcaaa26-d888-4426-ae8a-7451f876f951","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"71775312-66d1-4469-8ee6-86dd1eb991c7","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"0fc6d721-3e6e-40ea-9224-7eaa597e660c","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"628afd51-fd50-43e7-a800-46ab9f6b160e","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"7863f7c7-ac33-4b73-b012-f4b8133f0f99","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"f11f4379-835c-4151-b930-5275b894db91","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"c766acf3-51d0-4cb3-acb8-cdb286f96daa","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"0962375a-9ef5-4271-bf31-952b2f767787","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"b9c7b27f-5150-422d-be6d-fe93587f8c72","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"339a61aa-5eea-4508-9d5c-3245ce55c17d","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"d6023250-8165-44cd-83e6-9ff8b9566736","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"c67cafc1-5067-46b3-858e-18038dbea6db","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"c74eaec9-ee1c-42b5-8cae-1b8adb9a82f3","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"5525db93-457a-4fc5-a6fc-18e96adddf92","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"301695fd-8269-4df7-8cbe-6351f922437d","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"d26aafad-a397-4a7c-bb21-e72167bd23b0","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"33e5cc6b-ac5d-4ff5-9c40-0605461fb1a6","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"71f53da3-b69f-4fa0-a8f4-95c2a289811e","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"06ad0b2e-defe-44de-9c4d-14626314f783","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"7a1c01a8-1053-4db1-98b5-c5c04ac5b4d4","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"2ea15af9-7ce0-4ed3-9829-fb60bb201477","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"e7de099b-81be-4b11-9ebc-36b30176735f","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"761223ef-d3ee-4d04-b021-022d53b5d775","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"31e595a9-e9f3-4d97-a659-b7853f932f49","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"6950aac5-961b-4500-a935-d5ea3305874a","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"8fd4ec7d-0882-456e-b34d-1eebdaabad89","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"382c8e90-60c2-4078-a60b-6cadd7d3df8e","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"e122794e-3708-49ff-8f40-7ea90efe8cf5","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"52bc1fee-e93a-4f68-ac52-722096d1a4e5","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"2f8b5a10-021a-4e7a-8a76-45f582abdc2f","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1}],"received":1477481641489}');

INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RECEIVED, DATA) VALUES
  ('9271229e-0824-4098-8477-1a564c0acca1', 'b222aa15-715f-4752-923d-8f33ee8a1736', NULL, NOW(), '{"id":"9271229e-0824-4098-8477-1a564c0acca1","groupRatingItemResponses":[{"id":"39d6fda0-4e76-409d-8192-081dff39e98b","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"ffc47c0f-e865-42de-9c42-1667bf6669f5","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"8590b122-8195-4005-b01f-bbadfc27358f","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"5b4f51d0-b93d-4330-a1d2-372ef9b11d12","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"d488d8c9-b82f-4565-82c1-771550e29bbf","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"37e5c8b5-dca3-4650-b3e0-30cd170998c9","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"8322b904-76b8-4809-b662-292ef001e2db","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"a833bee5-e498-4fec-aa29-fa70846548c2","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"b41fb5b3-ed14-46c8-afba-592dee0f035c","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"bf763e8e-4b66-424a-aa0a-258ff8c9c60e","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"3a827773-de98-419f-b919-35818ec1bdf2","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"ab3113e6-7482-4673-b04a-fe39cca940ec","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"ae4e10b6-4b04-4e28-ab7b-d7d3329f97cd","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"f71efc21-7129-4f9b-b3eb-9e7eafdf07bb","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"d31e1dd0-0b3a-4117-9dcf-dd2a3108bb1d","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"92a49e3f-044b-4f77-8098-0f080bfca1b5","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"810e5fcd-767c-4776-b0d2-a34c4edb23af","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"0ee5efb4-5ecf-48c9-90e8-78e36cfc16ed","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"81f6ebca-f235-4694-856c-627550e5ec46","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"9f1af854-4bc8-48ed-913d-85e3c21e7edf","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"d1681c4d-6626-4c3a-8ba1-7eed062f3831","groupRatingItemDefinitionId":"f4f646d8-d9ff-4ee8-bd6d-f521c50d31bd","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"1bd04825-5901-456c-a9ba-ec19cae9c4e6","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"b7be5a18-06da-4d87-af80-c0b1c00b54d4","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"6de315c2-7821-4e33-be51-6421a6de4c40","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"4271266a-fc33-4500-b607-1ccab9ef8df8","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"615b3283-a3c9-4c0b-afc2-6bb8d55a421e","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"88b6b109-43f0-4435-b4f8-61535f298fb3","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"42457cd9-93fa-4d55-852f-e16583ceb668","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"2580f745-b672-4cf1-9917-7c3e107dea07","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"13dd45bf-9525-4215-af7d-7274f6058610","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"2cd4ae39-556c-4c33-924a-ff293baadaaf","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"cd974e73-2618-4a27-be10-ce4ce9a60b52","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"c24d33ce-f89f-48cc-8084-611c26af22be","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"6c3e9b64-239d-4cd5-8369-9c66a49cfee4","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"df4646a4-ded4-48ff-85d0-a21e528b390b","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"64d86b9f-6cea-4c56-85e5-4de6b6081e72","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"afe2d8e2-3f18-40bf-9686-f9fd11f27c6c","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"ddaf9488-facf-4dc5-af97-1521e57a4f7e","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"470fff84-1b46-4e92-a147-c048450db50f","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"e14c71bd-a7fb-406c-b676-660daa4ec67e","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"3bf9b1ac-47b5-48bc-9361-2321829328b3","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"3eb2bd66-4a6a-4899-92a5-9035b7570000","groupRatingItemDefinitionId":"eb24cdd3-2be4-4fe6-bf9b-6de3ae065e67","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"b4346b10-cf2c-422a-8500-a34c0c456b01","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"9058c35e-ba61-4854-8e5d-8616941d99f5","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"c4b6586a-7e33-4000-9abc-ce23c3ccc3bc","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"8a51e161-922f-45ff-b5f8-d91fd3238081","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"4fe83205-568a-4054-9f4c-8da497ebadf7","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"b42b28a0-0157-49f1-890f-8d47fbc52536","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"3f47557e-c2dc-42a3-a81a-373c5bc9e55a","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"55906bf3-1fed-47c7-9535-d1b01c559b14","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"9f03a498-a8e4-4900-867b-50f5ddd359d5","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"b77c5755-cb1e-4561-97b9-68dd89de6b9d","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"4344b452-a512-460a-976f-582d831a390a","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"28920f4d-6314-47e8-b557-9cadd636929c","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"e3977b31-eded-41a8-b5ce-6d82e4328490","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"79a3816e-a7e3-4866-a4c0-a4c16a6dbbda","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"61ed8ad9-4d98-4057-b3e4-1637e548303f","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"d9f9eeae-eada-4d08-9201-4b9c9d55e279","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"17c74e6e-e925-4fd1-a970-f291c410dda5","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"fe9f95b0-0a43-4f7d-88e5-4825664b47ac","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"aa03594a-ea33-4038-a827-f9306e02a46e","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"c49ca43a-3449-4261-8fae-ebb968ccbee2","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"2de2b301-a1dd-4e48-86ac-b6caff059034","groupRatingItemDefinitionId":"b22716c0-faed-4a99-914f-cd291d994a62","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"85a7f307-9ea8-4385-807a-4e32e8f3be68","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"212dc1eb-2c94-4cb4-abef-1e91647f00c2","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"fd7a903d-9de0-4950-a0b8-1ffe3d51214e","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"07218a80-fb89-4a3c-9416-18ed88b06105","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"13835430-0ba0-4387-8d58-dd366f7b29e1","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"cc16b13f-6ffa-426f-af61-65a1775238b5","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"596cd9fe-d0a1-4f95-aa94-e65899dd32ae","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"33303dbd-04a8-49b1-a3f4-d9d72cd68ae0","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"cb7244ff-ae36-4a93-8fcf-d1716b97b782","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"eeb9ab53-4406-432c-a064-97eee62a9de2","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"ab119f54-ce98-4e35-b38e-a31f947ffe44","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"f9ffda27-42ca-4021-afee-152c8fbf930f","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"e6590e0c-0900-4311-b4a8-8bb1ae38d0e8","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"ae31ff55-045f-486b-97d1-587fc1075c2b","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"94586da9-c3ee-4ff9-9253-6937798bc9a1","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"3351d933-db24-4e11-88ec-1b3800e3ece9","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"9f0de063-8d83-487c-991a-094c86f9af36","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"655c4075-a3ef-46b6-b9ff-02a4a8107f4d","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"05651969-b36f-49c5-a517-efd27904a6cb","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"b551995f-e0f1-4d2d-9b96-56fa5b3bfce3","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"a874446a-8aeb-4ade-a765-30fb4cc40a4b","groupRatingItemDefinitionId":"f5d938d4-08a0-4468-bbaa-9aa955f0a46c","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"6341e25e-53b2-4487-88c7-17c2ebbb0642","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"304f7b1e-50c3-484a-8506-02e5aad90bcf","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"fefc32c6-5fd6-4056-83cd-dc22c7c80c6a","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"d77ba191-9bed-47f3-ba39-8083a7c7110b","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"431a2f5c-9242-46d7-b5a8-fb94a4674fb4","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"f719b728-5a51-4132-bad1-56a53594d994","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"b44d1dca-59aa-44bb-9f93-98436bf16c8c","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"36f6b81f-f13e-4d02-be8b-453ea166c1af","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"45349255-d3e9-4a10-9186-6f1017accc17","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"6949251a-3ea0-4348-b486-71fdf710638c","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"26d9c1de-e65b-484c-8668-7ae45cbbd891","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"eca0c848-6891-4cc2-bcf9-a31510c8338c","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"f604272d-e1ca-4205-85ea-eb19b6816f93","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"4d6b111d-675c-432d-9058-d41a857c5fe6","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"0ecadd19-a544-4b53-8ee2-779965351377","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"b1132fa4-94ae-4152-ad75-2909d20eed6b","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"f1e79a09-f507-4818-84af-3bdc88dfaeda","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"8919bfa6-37c1-4c74-bd23-f69629ca79cf","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"e1219417-9018-4016-8a24-fa05ec4c0499","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"434eedd8-776b-4005-9130-97e2b2ce36bf","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"8c8cb34e-94f3-4037-95a7-f9854e42ec4b","groupRatingItemDefinitionId":"878fcaa2-f532-485a-bf09-e1815223ea86","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"d0594554-2ec9-485b-9d66-b3ea0b2f617a","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"2b2e4d28-4907-4d6c-8c68-89647c5de8a4","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"7011eb23-65ac-4c8e-8865-4ba7c6cdf6ee","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"38ccf16f-3e83-4feb-9211-80f78571f10c","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"5cb027de-1175-4b6f-84bb-6fc52d95940c","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"406b05a2-53d6-4c93-ad6b-f4c7f2c04c91","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"4c4aead1-737b-4409-ba81-7400fc67b6f2","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"93991c5f-2818-4dd8-ae7b-bd4be64fe62d","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"70701eb5-a4ed-4b7e-ba74-90ac561677cd","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"5ff45001-d840-4b51-a751-8e7be79829ae","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"7f98e845-3382-48d8-93ad-d28a63564f8f","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"c06ed958-cb92-4e4f-aa14-9b3dc61522f0","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"d429ac54-aad4-49df-82fb-b18ffaeb987c","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"0719a8c6-542a-4d01-946e-250803dad4d5","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"b9fc7824-3f2a-4c5e-88bc-160bd24000df","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"06386414-229d-4f25-8f83-8dee47a872d7","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"3d164624-2c08-4dfa-a6e3-9e34f08ea4fe","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"c47d5e30-9609-452d-b091-48acb15db964","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"169479d6-855a-4073-ae41-bfd24b24f22c","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"a6e8de65-18aa-43ad-8aad-af569590d973","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"5a3ac4d3-3766-423e-93b8-1039d7006804","groupRatingItemDefinitionId":"99f9c5ea-2c2c-4f5c-8f89-9a866e3331ae","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"fa156667-330c-45cd-baa0-e497a4708a13","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"9e381ab9-ce75-4c2d-859e-2b00241e8aae","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"0422b881-e547-4903-b95b-bbb787947f44","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"1846f0b1-18de-4f4a-aef5-3d821ef429ec","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"5363a03a-1689-4eae-a476-03f729ec83c7","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"c7c77d5a-18d4-4275-a739-fb36e6815e0a","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"e2f96d0a-088e-4b6b-8260-ad0eb7291fe2","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"4857e81e-49ab-4599-840e-953942d0653a","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"432ff161-2eb5-4aae-8531-40d70faa8206","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"bf00e2aa-4274-40d7-bc38-7a5beb34c098","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"39bd6394-370a-45d6-bf59-f97ee5096036","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"3628b571-77d7-48a1-8fd3-a068ad5b0987","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"c32c31b2-17b1-4da4-92c1-4e238df2cb32","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"be671747-503c-48cd-a87f-27751b5e52c1","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"47f94df2-49e6-4d24-8664-b6dac1e5ced1","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"3f2df0a7-ec65-43cd-aa47-69b84f6cb5cc","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"2a1490a9-37d1-4bb7-a2cf-9ce43c11b7ea","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"17d09933-b0de-488d-b149-8cd099695386","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"abd40b46-169c-4f33-bd58-d49bbe4521e9","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"4254ccd2-0766-4439-9426-2f09ae40434a","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"74f533ea-c1cf-401e-a974-2b97795361c4","groupRatingItemDefinitionId":"f0c31536-94b1-46a2-9e47-1ae8be36fe8f","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"ae4bb2d2-2c79-4e0f-9fd0-c6e75114c790","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"5a506785-42b3-4075-bf28-32def14b7a2d","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"20e51f03-1f50-4c02-8997-c76bb9e574c3","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"9c1b0a2d-2184-4a3c-bec2-b9eb5331ed8b","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"e5ec3844-d970-43b1-b2ee-5b6cd44c1476","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"1e18aa42-fa6f-434a-b92e-4472fb519a46","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"8ee45145-d8a3-4a8b-9206-3f51ec1b6604","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"b6eb77cd-42c0-4e40-98a0-b8992508cc10","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"78240046-2e2c-4d10-bff4-182a36c4b9d4","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"df3d649d-bf45-48b8-9770-6e460a9dd204","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"d5f193e8-5c08-408b-9e1f-28c78d77add1","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"953c910c-f606-4fed-8132-52d6e8c09457","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"509bf52d-6c14-4925-af7f-0feb518ff4eb","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"b3beefbd-152f-42a8-8dbe-08d1493e6533","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"2de82ed2-86a7-4fe8-aec2-197e37b15f21","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"c8623217-4dc0-43b8-be64-5ef403498b25","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"d1b91247-b0ac-439f-9056-c700116cebb7","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"61578781-c045-4ecd-be71-8effd0326e48","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"ebf05903-5ae8-49e6-8311-6bfdf0454c2f","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"a2c30cda-c70c-49ee-8304-479fe00ca4a1","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"8d4fecfa-3781-45be-a222-3fd0cd230fba","groupRatingItemDefinitionId":"09a57f34-0227-49c6-a80f-e2f73643fe26","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"d30986b2-542f-417c-843a-72e44088eb26","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"f409a731-b106-42c4-8876-424fd3089ed6","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"bd84f8ce-8d9e-4dbd-89f6-c90ace46fb2f","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"0f6c52bd-5b98-4b6f-8625-1938a8b28209","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"880fbe03-d46b-4741-816f-6ed02ebfe48e","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"8103bb27-3b8e-4a27-bc5f-72310cefa9a9","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"7c450d35-8d8a-4514-a68f-17f4ac1509d1","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"110a7258-0625-451c-8208-a99c70a5ab68","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"9d9add69-3e0b-4391-8683-0e93281f56db","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"627ba6b1-2d69-49bb-b3ff-e6a30903e04c","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"9ad0646f-6af1-4d97-addc-afaf69659bda","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"45614eda-3e9a-4371-9906-3a27580ce1b0","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"82067305-656d-44dd-8160-c4f286e8f36a","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"1c349872-52bf-4c95-bd72-2c955bb20042","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"ebc68d81-c9c1-4509-b7a2-dddd9ede1707","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"f152c2c9-e9e2-4c51-9c37-7e9085161c79","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"6adf12e7-894f-4bf5-90ca-0ce82ac5e049","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"b836b520-9a6e-40b3-aaed-6daed1b22aaf","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"abed0db0-41c4-4110-9903-fa619a6cf3ec","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"86bfa223-0dc5-4454-9f1d-8794fd704ba8","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"d3feb594-0d66-4c7b-b9bd-f45b150c5ddc","groupRatingItemDefinitionId":"230e38ec-cc67-456c-a6d1-1d09fe679800","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"1ccf95e7-3425-44f3-81bb-ab3c06b3754a","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f28c36cd-1a09-4e3a-acf0-dfb5101ca455","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"a4d7da3c-e2cc-4e4a-966b-37fc08730393","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"5f54bb9f-716a-452f-bf65-afa97381a50c","groupMemberDefinitionName":"Peter","rating":-1},{"id":"458465f4-472a-4c91-857b-2b6706b63756","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01c40693-27de-4445-a043-93bc3b814359","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"e4496f6d-4604-4541-83c1-d768bd71b514","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8524eed6-dc82-4bad-bf90-41c52dfe01f7","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"de3fc2a7-ea69-4230-9c02-b43162143ff1","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"29a95962-6e01-443e-9f69-3502b2fd69aa","groupMemberDefinitionName":"Dan","rating":-1},{"id":"6a2222b5-0a7b-4cc0-8ebc-afc3d8c35233","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"eb85edd3-baae-44c3-b107-e37a835d2093","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"3bda4aca-babe-4aa1-b1c8-a0c084ba384b","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2a4ea3ad-142c-404b-8077-7b14545715ef","groupMemberDefinitionName":"David","rating":-1},{"id":"e5c5e3ba-85b6-4a4f-bf90-926d1ba074e8","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"46a93633-efb3-4029-a549-b0b661f95253","groupMemberDefinitionName":"Francois","rating":-1},{"id":"3e8654e6-e13f-4dfc-a7fb-bfd2b829c810","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"64a15e88-b04d-459e-9dba-a5f8b174f85e","groupMemberDefinitionName":"James","rating":-1},{"id":"87215076-9742-4a21-beed-f3b1a55fe1ff","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf911f2b-6ce3-46d4-b027-1fdeba928c44","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"86bb7b7e-263e-463c-a0f4-57abdd40ec57","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"58abe9bc-4b57-4f9b-94f8-2e9dc6c8336e","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"1fc8e59f-d6db-4e60-bb76-199dc52bf9f8","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"38c0bd8a-5bc9-4fe1-aa3a-1dd49b73e63b","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"6be45bb7-b94a-437f-a428-d7ec6b7768a0","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"81485cff-e306-433e-b420-1c8b248dd804","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"5ad5aeed-5eb0-4d12-a4f1-b52c4b57968b","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"307cc378-50b3-41a1-b53e-b6ac9d5f7563","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"a1f95133-b2bc-4ef8-95d2-fde6b3d99797","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3d19129-6949-42e4-bac7-3e04d0ba31f1","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"2c618dd1-39f1-4ddf-a215-48e9b6c3a8aa","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e646f71-f5c9-430a-8ec7-d124a2313dfa","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"dc9d0102-cecf-4b35-a36c-84674743918b","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ea24bc86-8cf2-477c-9fb9-c0209c35540b","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"bcb5e4da-3c6b-417a-9857-22b9e035d378","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ca3c0266-a77f-445e-8dcc-8bbd2bdbe852","groupMemberDefinitionName":"Richard","rating":-1},{"id":"403fde79-ad7c-402b-a72b-700881574c9a","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec1daa2c-e4ec-475b-bc72-9a82574d0054","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"736c8c55-a25f-4023-9821-ac333864213d","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"962e40d5-06af-4743-882a-02cea33666c3","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"21439176-ea71-43ca-aa5d-cdea0ec22e1d","groupRatingItemDefinitionId":"689b52ff-f196-4a2b-85e2-b48a1ce0f1d6","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"cf5587d3-74ab-463c-b6c4-dfe0ac6c9f1a","groupMemberDefinitionName":"Debbie","rating":-1}],"received":1477481641499}');
  





INSERT INTO MMP.INTERNAL_USERS (ID, USER_DIRECTORY_ID, USERNAME, PASSWORD, FIRST_NAME, LAST_NAME, PHONE, MOBILE, EMAIL, PASSWORD_ATTEMPTS, PASSWORD_EXPIRY) VALUES
  ('0a8a997e-5899-4445-9201-d4f811069ac7', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'test1', 'GVE/3J2k+3KkoF62aRdUjTyQ/5TVQZ4fI2PuqJ3+4d0=', '', '', '', '', '', null, null);
INSERT INTO MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (INTERNAL_USER_ID, INTERNAL_GROUP_ID) VALUES
  ('0a8a997e-5899-4445-9201-d4f811069ac7', '74bd122c-74d9-4e40-95b8-0550f54a0267');

INSERT INTO MMP.INTERNAL_USERS (ID, USER_DIRECTORY_ID, USERNAME, PASSWORD, FIRST_NAME, LAST_NAME, PHONE, MOBILE, EMAIL, PASSWORD_ATTEMPTS, PASSWORD_EXPIRY) VALUES
  ('aceba07e-97bf-47a8-a876-c774ad038f8b', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'test2', 'GVE/3J2k+3KkoF62aRdUjTyQ/5TVQZ4fI2PuqJ3+4d0=', '', '', '', '', '', null, null);
INSERT INTO MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (INTERNAL_USER_ID, INTERNAL_GROUP_ID) VALUES
  ('aceba07e-97bf-47a8-a876-c774ad038f8b', '82b72c08-6544-41bd-93dd-f82c74477376');









INSERT INTO SURVEY.SURVEY_AUDIENCES (ID, ORGANISATION_ID, NAME) VALUES
  ('c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT');

--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('b2a72a4b-08f9-4740-aa5b-f7a5e690f0a9', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Peter', 'Rix', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('f6156984-6bbb-44b9-8a82-ee86dafbacc7', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Adriaan', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('ad7e91ae-1cee-4f91-b87a-6fde06e32acc', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Alapan', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('1cd8d426-6e75-4f93-bbc7-3992f4043bed', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Daniel', 'Acton', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('3eabd869-9b0e-437e-a826-d7af06834818', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Daryl', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('9bc1b70b-80f3-46d5-b30e-ebbe5de8656e', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'David', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('74ed0311-f884-4bd6-ae57-4421385a543a', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Francois', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('109b0cb3-54d6-41e6-a524-7105d31e6d27', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'James', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('a301b8ee-64e6-4c83-ac08-d96211a334a7', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Kershnee', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('3170afc3-6798-4849-9635-99365221d115', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Kevin', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('b0302932-6ddc-4c2a-a8c6-9dfa4c58b754', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Linde-Marie', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('51bbca64-785c-40a5-bef2-cfbc9fb503ef', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Manoj', '', '');
INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
  ('2105161b-0ef3-44bc-a5de-be47124ef5e2', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Marcus', 'Portmann', 'marcus@mmp.guru');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('225677e0-0da3-4efc-827b-3ab268c46b87', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Mercia', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('c412061b-61c2-4c7d-9486-ccb09118af42', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Nicole', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('10f89240-acbc-4a39-901f-843871d332ee', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Lawrence', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('0a92616a-3e78-44f7-9f39-00213e2f1af8', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Richard', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('6f1978a2-3783-4a76-a964-50258f1c082c', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Sandra', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('8eae4a3a-8863-44cb-a417-13488d551b83', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Tendai', '', '');
--INSERT INTO SURVEY.SURVEY_AUDIENCE_MEMBERS (ID, SURVEY_AUDIENCE_ID, FIRST_NAME, LAST_NAME, EMAIL) VALUES
--  ('e9b5276f-e1aa-4c69-960a-f7022431108c', 'c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'Debbie', '', '');



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

GRANT ALL ON TABLE SURVEY.SURVEY_DEFINITIONS TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_INSTANCES TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_REQUESTS TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_RESPONSES TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_AUDIENCES TO survey;
GRANT ALL ON TABLE SURVEY.SURVEY_AUDIENCE_MEMBERS TO survey;




