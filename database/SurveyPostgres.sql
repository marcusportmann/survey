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
  ANONYMOUS        BOOLEAN NOT NULL,
  DATA             JSONB NOT NULL,

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
  DATA                JSONB NOT NULL,

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
  NAME             TEXT NOT NULL,
  DESCRIPTION      TEXT NOT NULL,

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











INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, ANONYMOUS, DATA) VALUES
  ('806fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'Anonymous CTO ELT Values', 'Anonymous CTO ELT Values', TRUE, '{"id":"806fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"name":"Anonymous CTO ELT Values","description":"Anonymous CTO ELT Values","sectionDefinitions":[],"groupDefinitions":[{"id":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","name":"CTO ELT","description":"CTO ELT","groupMemberDefinitions":[{"id":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","name":"CTO ELT"},{"id":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","name":"Peter"},{"id":"18f9a788-22d1-4927-ab44-6df544b23e89","name":"Adriaan"},{"id":"649b4887-bfb9-424b-9032-5c2720b2343a","name":"Alapan"},{"id":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","name":"Dan"},{"id":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","name":"Daryl"},{"id":"01623890-e77d-448d-a489-b3941b5c6bcb","name":"David"},{"id":"babc462c-63c8-46e6-9039-39aed3896751","name":"Francois"},{"id":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","name":"James"},{"id":"c4c49d21-a135-4e92-98c0-641aaa74a897","name":"Kersh"},{"id":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","name":"Kevin"},{"id":"95d297f7-b71d-4de0-8623-6e90082c2c31","name":"Linde-Marie"},{"id":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","name":"Manoj"},{"id":"305fc700-2458-492c-a9ff-19643a538b20","name":"Marcus"},{"id":"be83e488-d011-4bdf-9d64-099e0d965440","name":"Mercia"},{"id":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","name":"Nicole"},{"id":"87dd14e2-77cb-483f-b474-f75028d01b02","name":"Lawrence"},{"id":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","name":"Richard"},{"id":"60be5e19-f504-4e4d-8c6a-82a3733543f6","name":"Sandra"},{"id":"51d2f754-e9e6-4bf6-9305-74428911a539","name":"Tendai"},{"id":"ada58705-4609-4282-bfab-6c645e41739e","name":"Debbie"}]}],"groupRatingItemDefinitions":[{"id":"21e08bc9-6173-4e74-9082-44a82f966260","name":"Accountability","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","name":"Competence","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"b6fef420-77d8-4bb2-9729-549111d622fa","name":"Courage","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"ba306b79-8e78-4f0f-90c4-382b819b2876","name":"Fairness","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"39c12b39-337b-41b7-b8b3-c328f62f208b","name":"Integrity","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","name":"Openness","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","name":"Positive Attitude","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"18e0def5-e974-4e1b-a6a3-0feecd146512","name":"Teamwork","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","name":"Making a difference","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","name":"Trust","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2}]}');
INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME, DESCRIPTION) VALUES
  ('43ba05e3-f6dd-40f2-9a63-9f201158e68c', '806fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'Anonymous CTO ELT Values - December 2016', 'Anonymous CTO ELT Values - December 2016');









INSERT INTO MMP.INTERNAL_USERS (ID, USER_DIRECTORY_ID, USERNAME, PASSWORD, FIRST_NAME, LAST_NAME, PHONE, MOBILE, EMAIL, PASSWORD_ATTEMPTS, PASSWORD_EXPIRY) VALUES
  ('0a8a997e-5899-4445-9201-d4f811069ac7', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'test1', 'GVE/3J2k+3KkoF62aRdUjTyQ/5TVQZ4fI2PuqJ3+4d0=', '', '', '', '', '', null, null);
INSERT INTO MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (INTERNAL_USER_ID, INTERNAL_GROUP_ID) VALUES
  ('0a8a997e-5899-4445-9201-d4f811069ac7', '74bd122c-74d9-4e40-95b8-0550f54a0267');

INSERT INTO MMP.INTERNAL_USERS (ID, USER_DIRECTORY_ID, USERNAME, PASSWORD, FIRST_NAME, LAST_NAME, PHONE, MOBILE, EMAIL, PASSWORD_ATTEMPTS, PASSWORD_EXPIRY) VALUES
  ('aceba07e-97bf-47a8-a876-c774ad038f8b', 'b229d620-bfd7-4a7b-926c-5041da432ae3', 'test2', 'GVE/3J2k+3KkoF62aRdUjTyQ/5TVQZ4fI2PuqJ3+4d0=', '', '', '', '', '', null, null);
INSERT INTO MMP.INTERNAL_USER_TO_INTERNAL_GROUP_MAP (INTERNAL_USER_ID, INTERNAL_GROUP_ID) VALUES
  ('aceba07e-97bf-47a8-a876-c774ad038f8b', '82b72c08-6544-41bd-93dd-f82c74477376');









INSERT INTO SURVEY.SURVEY_AUDIENCES (ID, ORGANISATION_ID, NAME, DESCRIPTION) VALUES
  ('c6e1bd3a-52e2-4e72-b49e-4f83445ac661', 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT', 'CTO ELT');

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




















INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, ANONYMOUS, DATA) VALUES ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT Values', 'CTO ELT Values', FALSE, '{"id":"706fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"name":"CTO ELT Values","description":"CTO ELT Values","sectionDefinitions":[],"groupDefinitions":[{"id":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","name":"CTO ELT","description":"CTO ELT","groupMemberDefinitions":[{"id":"751b401d-7d84-436c-9c43-d17464cab85e","name":"CTO ELT"},{"id":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","name":"Peter"},{"id":"9139909f-6b4b-4e46-b315-b41aa049f60a","name":"Adriaan"},{"id":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","name":"Alapan"},{"id":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","name":"Dan"},{"id":"a78654b6-07a3-4cfc-a54d-46889caf6a83","name":"Daryl"},{"id":"3115a850-7f26-48ec-82d4-7b67a5201182","name":"David"},{"id":"c3292070-c7e0-418a-9e34-9970912bc168","name":"Francois"},{"id":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","name":"James"},{"id":"5231f75b-9714-4eaa-ac60-5f890a5326e6","name":"Kersh"},{"id":"727b939a-eb52-4b0c-b30d-b33470b05ca2","name":"Kevin"},{"id":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","name":"Linde-Marie"},{"id":"c914e21e-2e19-425d-a61a-9f78233f3a4c","name":"Manoj"},{"id":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","name":"Marcus"},{"id":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","name":"Mercia"},{"id":"5b26f4ae-87b1-4938-8979-86b93eb1232b","name":"Nicole"},{"id":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","name":"Lawrence"},{"id":"bc166278-d513-4142-8319-231ec19ff932","name":"Richard"},{"id":"dd6886bf-8745-4253-a420-d0db877c4b92","name":"Sandra"},{"id":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","name":"Tendai"},{"id":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","name":"Debbie"}]}],"groupRatingItemDefinitions":[{"id":"3b6df123-d1a6-449d-87bf-2e950357b353","name":"Accountability","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","name":"Competence","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"85af4470-f5f3-4d84-9b4f-50a66ac12345","name":"Courage","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","name":"Fairness","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"217b46ee-7162-4e03-8d20-9f44ef6d888b","name":"Integrity","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","name":"Openness","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"597e9a0b-91bd-45a2-944c-7e13a1265f41","name":"Positive Attitude","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","name":"Teamwork","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","name":"Making a difference","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true},{"id":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","name":"Trust","groupDefinitionId":"0ed6e8d7-efdd-4014-b97c-a0d4c7d1f70a","ratingType":2,"displayRatingUsingGradient":true}]}');

INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME, DESCRIPTION) VALUES ('b222aa15-715f-4752-923d-8f33ee8a1736', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'CTO ELT Values - September 2016', 'CTO ELT Values - September 2016');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES
 ('a570cbce-392f-41dc-8bff-219abab90950', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Test First Name 0', 'Test Last Name 0', 'test0@mmp.guru', NOW(), 3);
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
 ('0fe9f7fe-8986-4f80-be94-514c40a3b1c7', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'a570cbce-392f-41dc-8bff-219abab90950', NOW(), '{"id":"0fe9f7fe-8986-4f80-be94-514c40a3b1c7","groupRatingItemResponses":[{"id":"f1efaafb-8380-41ee-8b4f-97d5317ccd1b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"b3d177e3-cf78-4e91-9e19-31bf04a2aaf1","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"1c0d2c44-42cc-4760-964e-47890f694e74","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"9be3f969-2d44-4bda-9975-5231c8dfed14","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"425bccae-a905-4e8b-90b0-4e7f72b40748","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"394795eb-5a50-43e8-be8f-9ddf9a467f25","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"80c42fe9-bd1a-467e-bd3e-27a1b5290a04","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"c0a38490-119c-414c-8d57-5f94ea419e16","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"435e1d36-2118-4c54-8a1e-87442ffe2199","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"dbae3b02-4db1-434c-a2b0-d9846c08192c","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"ff9623e3-9505-4674-8471-892100a41f41","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"564d475d-2c3b-4b92-9f16-6ef1306e8265","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"f9ec7438-2073-4619-b8a2-f8affe70b1f8","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"8f72192a-fe9d-45de-a64a-3951bc706170","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"469ef7cb-070f-4939-8f29-3b5d3b24586b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"8f02537f-8dae-417d-a295-a8f763503436","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"73fdd262-9dc6-4a99-90c7-1d840ec6883f","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"a00fee53-0dcc-4af9-8a90-e974e8675fa4","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"180f6dad-3653-4822-b3b0-32083ba65fad","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"96b7b918-0182-466d-806b-c23ab2e38aab","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"280a6fa6-3f57-4694-bdb6-48b6fe88eaf4","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"ec78ce10-93a8-4e4e-a4be-d8ca0a8872a8","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"8cced5d3-0a77-409b-a415-7697a7f8faae","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"f2d23839-047a-4145-922a-23cc0fe797d2","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"d9040557-d84b-47c5-b32f-03671ed4dc88","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"9bd22721-f392-46c6-b90f-1b3f57b7202b","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"5173e590-ea0c-4ea7-a32c-383ea597ec70","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"82805451-b22c-4297-89a5-6cff51dc94a3","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"2132eb23-265b-4005-a1fe-c1e4ed0939d3","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"ddb8a4aa-69ce-44f2-b225-1bdd541e5155","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"c26f5f6f-92de-4b19-ad2b-30e29aeb3a27","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"d1d950d0-2a2d-4242-94c8-e88f846bd7c7","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"4c04cefb-be05-4391-9290-4621dc23f04d","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"5704a5d6-3e98-41fc-9cfe-3a89d6cafc67","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"d4717d8c-bd8a-4b25-bc7f-998aa321aa78","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"7eb0d256-c565-48d5-8c96-4c201c150649","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"dc7b5a1b-2c25-457a-b72c-fb28c8ba4fcd","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"e68c187d-c332-4520-9b3b-7d9344635a1e","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"22dfdaa0-da3e-4a94-bcf1-6d00a94ba812","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"861ee710-d8fe-4d34-8392-a1a4585e542d","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"d19b45d3-020d-4544-b0f6-8be5fdaf8e80","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"d051911b-5b91-465a-a976-f3fad9feecd0","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"c09ca2c7-ce65-40bc-9f32-f3f2778a5910","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"5b6fea84-5919-4866-93f0-8bc8834df670","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"4cf06f4a-ae71-429b-bc04-23e666449cf2","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"7fbc2520-753f-42bc-94c1-d0bff1287a21","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"feaa1839-f243-46e8-ad0a-eec233bf96ef","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"c423e5e0-a5ba-4b8f-8dce-241e7a72741f","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"4c8c8337-9f37-4be1-85d1-58bd8f50d81e","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"4f00bf0d-18e7-4727-8231-9c25226d8e7e","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"801f2979-d4fb-4a47-ba07-1afcb224cfb9","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"51b68151-3628-4e08-8da2-4b65423e32a8","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"ad7d565a-ffe5-48ad-98eb-789d6f185f92","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"b6f5ffda-1e07-4b58-9634-71e813af0e08","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"2ecc5cb6-445b-46e1-bc9d-1a3130e019c8","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"68aca8e1-84d2-42c1-9394-614bcf000268","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"372e4c02-86d3-4441-8fca-4960873452e3","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"2fb8bfe9-8b7c-4959-8f96-c8ed25e2babc","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"08b9c981-72d5-4e33-bc0b-127dc7d75b82","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"e483da53-4f8a-48cc-9efd-d58203b4b0b6","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"56ec790c-16dc-4003-ae22-eb2dcb4d985f","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"8e33260a-8638-4440-901d-a07166fa252b","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"2835145e-b9f2-40ed-bb0e-59b3a755f195","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"5ddbcd79-9e24-4bc6-b6e7-cde7f85a814e","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"93453657-0ff3-483c-aede-60c280670ce1","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"f3586f85-3ccc-4122-821a-a8525b313e7e","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"5a9aca85-6333-4761-a33a-0a681c12e4ce","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"e7b687e0-0ecf-4afd-811f-da4a90b14147","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"04422e43-2c69-48ae-abc2-0f226b176ffc","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"e16ae50c-9d77-4825-8b3e-1d7267bf19f4","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"178e85b1-5143-45a8-b811-f50985180e76","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"4ec391ce-3436-490b-b6aa-6c635f0e94c9","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"394465e2-8e3c-4787-b9a7-0e6817302f80","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"9719b3c3-1c6c-444c-a3e9-66d36518462d","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"0e76dbae-721b-4539-88aa-382fa744dea4","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"c2a8c4cb-b3ca-4bac-8ce5-e49eadba6a89","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"5c8b1540-0611-40eb-9140-2b3bdf2544a6","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"40132346-e890-44cd-b72c-f377cc8d1bc2","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"6fc2ac0e-ece7-4d6c-b3f8-f5a0cc86fb52","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"419700a2-8e93-4dd5-be26-6865a1990ea7","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"034d4c61-08f3-40d6-a2e8-0a3c70942982","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"f162da2e-8de5-4ec3-a446-6914f260f17d","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"724ecce9-4dff-4844-966a-9ed1e58aa6e4","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"58e00e48-e58d-4b11-8d7c-e00f98a6efad","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"a756f486-5c6b-4ea5-b361-33f2a5031e51","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"c1ca92a5-caa5-480d-a13b-83bf3a3c52e8","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"d6069ca3-2cab-4bc8-9393-391260cc9d1e","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"b86ccdac-1efe-48a3-820c-f7b9bc06dacb","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"0903998d-143f-4825-a954-d88a11c3f498","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"4b59cd89-3976-4cf3-8008-d19f12c35ccf","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"5264e1ac-9d3c-4607-9759-072a37c5dc72","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"935aec05-0420-4d0e-8347-5d40cc102564","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"e594cb56-0327-4764-ab75-baa92ce6becc","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"2243b760-b825-44ec-b07d-07ad9078cac0","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"087c0e26-0407-436d-9b39-533707a88863","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"dffd24bf-89e9-444d-a2be-740b9c15cc3b","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"900dc0e9-ff82-4d59-a245-6216c84ba49b","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"af04edc7-e509-4400-a551-893cc48207bb","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"552cdaaa-ee8d-4b1a-b349-bf1d522dba76","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"a030a0c5-b7e2-4239-b418-0fc9a4905d93","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"7c3a69f0-dd29-4b6a-affc-5a8752688385","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"5f419198-da4e-4db6-b290-46b87ee5b817","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"7c557e09-a997-4580-a69e-92ad3ebfd064","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"92b5192c-0e40-48ce-934e-38c862c8d097","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"27bd190c-cddc-41ef-bbd9-d9bac3ce5371","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"f7b0ac66-a2d6-4bba-a8eb-afd46d0f4b14","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"e645114a-19e8-4f8a-bd7b-b3e31250b2e5","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"dd0862b9-752d-4275-89e0-eae94124fadf","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"9e997777-f0d1-4e0b-aa14-aa4d135004f6","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"3856ab6d-765b-417e-b3ab-64fe3d4d8d05","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"b292e85a-3e45-441c-b89c-4f0ad677f71b","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"b80c617f-d463-483f-8e84-47901b732c4d","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"ed53994c-0cf7-4639-bfa4-4c58a364a23a","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"e6de2fcc-5818-460b-b761-4b7bbc647771","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"484e2a13-7373-4468-b3ea-455f246e477c","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"dca99183-5e32-429b-96e9-edbd19ec5722","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"2deb7e36-c2be-44eb-b7e6-5f38ec4fc6d4","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"2925a197-dec0-46f6-8a52-cd7462c78545","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"1e567096-5f0b-45dd-92ba-128562de5fea","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"9d927aa5-beee-4f42-9a49-4c971c36aba4","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"55706896-8fc9-4d8c-a41b-2f6b1c400cb2","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"2173849d-77ac-4174-9d97-52ff4e71ebf6","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"af898d66-fb10-4a3c-abd8-e59c74aba021","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"42a7ae6e-b677-4936-8c69-f8a7d06312a9","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"b8c3973a-2f07-49f3-8eea-636feaa21168","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"83553158-5051-4412-a62b-98a0532054d6","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"0fbe037d-1a43-4c48-be15-928100157689","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"9c6d4415-4160-451d-aad8-3dff77ced376","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"9f62201b-f3fc-4e0b-942a-950fc70ae2b5","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"c0e63afe-376f-400a-b4b0-9305b55729f7","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"c189e913-a0e7-4070-b3a5-5ac5c6facb9c","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"d084a622-eff3-4130-b381-5e43dbbbce2e","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"fd3568a0-8751-4330-bd7f-527f79e3f61a","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"b5a7fbdc-24f5-4bfa-a5c5-43af7d39e179","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"de022ebc-6b34-4b97-bbda-6d050833802c","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"8cf90d92-75f2-4cc5-831b-ccd6efbb7f38","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"2932e2d4-afe2-4870-a4b2-a18da08f74b2","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"ffb35422-b3ff-48e1-826a-d2b7237fe20e","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"18cc12dc-1f03-445e-be10-099367653e71","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"bc52d5ab-af3c-41c9-b3d3-2126479313b2","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"c6b5e596-21e8-438d-9a81-b9e400ce2052","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"2de15d85-f049-4cb3-8cec-038983e9b7c6","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"632e27c8-0366-4f39-bc30-ebbaffab8c69","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"4ae0afa2-313f-4903-b536-e709efdbb049","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"dcbcef35-3cbf-42e4-bf35-5894b52ef00e","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"4ad5bbf7-1fa6-4f78-b6d1-ec4efcb3de53","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"fdc7dfa3-c39c-4d2a-a3aa-de11c276cd5f","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"3134b987-0fd9-4640-b756-3b7a27453277","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"f8f17ea5-8af0-4e44-8607-809c4cb1eb9f","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"3b6c55a7-b2fe-4c76-9c5e-713f9c40e031","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"0efd8371-2a02-4058-8309-00b38320db44","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"62ec8817-d073-424b-964f-053deaa80c64","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"f1473889-4360-454c-988e-1bc011922e90","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"cb294cf1-b14c-424d-9c50-0306952a9361","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"f98b643d-6ad2-4cd8-b2fc-5c28c1e528f6","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"f4481f94-9cba-43b0-ab79-baf75c7aa598","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"bff6b997-f1ea-4589-984f-7b24645d7682","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"f77a57db-1c64-4385-9dc8-8099bd3ca6c2","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"6c22c4a4-ad68-44c0-8a45-2fbfba70fc59","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"c486fb17-9bd9-4504-924c-8cbae767964a","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"398c0a11-0996-4a25-ae4f-99e746548c07","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"c988027b-22f9-4968-812c-3c6b1e993aa5","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"9570e357-3896-41a3-a259-a2f581a52fa3","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"2f5c9c8a-155c-4e2a-b33c-4a985d2750e7","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"f30913a7-b42f-455a-8723-bf585d6ce124","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"80280517-e349-47e7-be59-33ee3c745a41","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"e21ab95a-45c5-4056-b54f-097221fd0d64","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"8ee33f9f-678a-48b6-969c-5153aa0cf2f5","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"519662fc-7a54-40aa-87ee-2a6e79384cd6","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"cd3f00fe-fa05-4833-b07f-ce83d7d7f16d","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"ce6563ec-4451-4cc0-814d-c8d97aaa5ef4","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"6c8753fc-422b-4260-9f34-f0533778e1a8","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"7b8f6196-0e7b-4ef0-9654-f15eeb1dd572","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"67f343e1-d129-49c4-a889-70e0515bf9e4","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"859f831f-f586-4a19-956f-f00b308e17bc","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"cebdbfa9-9c75-4afc-85d4-d929c1dfaa8d","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"92b6aca9-17de-4dcb-9714-8d7ca8b6bb32","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"9d93aeb7-fd9e-4d54-a468-f159b83c5801","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"e112b22c-2679-41fb-b1ea-146c79ec1a02","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"29b5a785-07bf-4a92-b5cd-94d5b1bbaedf","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"a6fe082a-8cfd-4065-ac23-7a13d9a78723","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"17310be7-2156-4880-aaca-689f82328281","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"9d95ee3b-1f3d-406b-a4a5-faaf7c9bdee1","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"8f975f27-b9f8-45b3-b17d-2558e7aefe18","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"201380f5-4113-4efe-975f-496fa61a6e9c","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"8411e7b1-40f2-41fe-a9a7-720a97229756","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"6bbd803f-1a57-4e63-ab61-fdabf7cb0dc0","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"8c66d11d-01b5-4a0b-bae0-6b12001ef9ef","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"ebafcb18-1020-4cb3-9d23-f90173aba882","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"709e2339-e4ff-40fe-9e73-5be8163fd651","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"dfa3ddda-b99c-44a6-ae3a-6b23818591e0","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"0b35f55e-7cff-4938-8d95-f8ee39cf8e3f","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"c4a3bf33-7cc9-48ba-ad9e-be04b27d370b","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"7084e5a5-524b-4e91-9c7d-0ec8b7449da5","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"f1633026-84d7-4037-a381-1995748a451c","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"4fe1d90f-0875-4448-9c9c-8d2026670071","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"77c72d91-0cce-490a-b209-a52a099935d9","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"7ea083c4-c1af-4f1e-a4d2-74e93be967c5","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"fbee4e0d-94f2-4aad-8e1b-bb15b358d56f","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"9bdd575c-4b90-47a4-80f5-0e3c5e4f4234","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"a7a06048-7cff-48de-b911-3584a312ed7d","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"f21adec4-f613-4a7b-abfa-ceb12a1527c0","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"d75b4f32-19f3-4335-b70e-52f108805839","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"c22be138-8c03-4fe9-bf60-f76fa60fcc11","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"9c9e873a-879c-4541-b785-b7afab47299b","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"9c6bc888-dbd2-4470-8b91-a3fe66997482","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"f5ed822a-edf9-49ee-b9ea-2be8f45ebf7c","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"07c049c1-0a44-4649-9e37-d8187781cded","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"f8cedc1b-97d3-4ab1-bf8f-7f9b13a6e778","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"05b4acd2-9102-4dd4-920c-af90f806b742","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1}]}');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES
 ('b79bd624-c45d-485f-9b6f-1fe69f17dc7c', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Test First Name 1', 'Test Last Name 1', 'test1@mmp.guru', NOW(), 3);
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
 ('49f584de-fdb4-4155-b2d1-c392a8cdae56', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'b79bd624-c45d-485f-9b6f-1fe69f17dc7c', NOW(), '{"id":"49f584de-fdb4-4155-b2d1-c392a8cdae56","groupRatingItemResponses":[{"id":"403450ff-de0b-46e9-a187-c6319279667f","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"7d429d09-1f40-448a-8b32-9d9e1f0fd261","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"96b9a9c3-b24b-4f04-9757-efd503045d33","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"bd9abc4c-eae3-4313-b8c7-6ba6aa20cb82","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"3ddae6b7-6166-4580-9f2f-dfb173bcce16","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"193e2b34-2c63-4c13-b5cd-f3bb57bf7e6f","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"37cd0c7e-c478-4170-a0c8-0ccc1989a837","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"c2b4a1f6-39ec-46a4-bd44-406f3b71b2b2","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"8f25ad01-e99b-4bdf-8559-536b782234f3","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"329ec7cd-be05-4f83-8a49-4528b8bf3177","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"002fef8c-22cd-4256-8789-b302200ec110","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"ec90af2e-ffc5-4dab-9a75-58fe8bd486e0","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"ec912851-c393-41d3-94d3-8d1136558a39","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"d17e655f-bf00-4078-a55f-892305796b34","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"432fb786-447d-472d-a6c3-155dbfa50a6a","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"6dbd4694-2503-4166-a89e-3f8231003fa8","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"ec228fb5-4c7f-4993-90f4-5a34205acf45","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"cc089ddd-906b-463a-bec1-246aecf1b573","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"e7f2f616-bcb7-4da9-9f39-de3ef38c16e8","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"68fa4311-6f92-4d72-a09b-0616900fd797","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"e545f1be-0b88-471b-8bac-ec0012f8a1c5","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"da81ec5b-f5d9-4589-ba8e-600110f02801","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"250b3c58-2e4a-47dc-a47d-8d252125e8a7","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"da74a15f-f3d9-4d6e-9723-2399fa93f8b5","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"753ebda5-310b-41fa-a7c9-d78577ee41ae","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"95990855-4a5f-456b-b637-91454d04400c","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"14f252f2-2882-4dbe-a88b-27363d8b71b9","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"9cd3b4a4-cee3-4de9-ac0e-ce10c9373af2","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"b8b86648-776c-4c2f-bc67-93345a7bffd8","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"d8f16613-5292-4efd-9a83-82de68a92f59","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"e3656af7-2c12-4978-ae0e-4a875c745123","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"5fae1a1b-2af8-4edb-aab1-1aede6b16d4d","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"a44fd81b-ce72-4ba7-adad-c8cb7a90bf52","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"44656c2e-2be9-4d2d-91a1-bf910aebc970","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"ddfd2a71-d1ea-4983-98b3-017d2f891abb","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"6f8b7928-86f8-479c-a796-d144e2a0b0bd","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"c7d02cc1-1947-4a32-8ecf-25a314a14922","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"1096e9c7-ad47-48e9-8b54-efd6ef965870","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"7f629dae-9310-4436-90ea-dac3602b69b3","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"e1dd33a2-c595-484f-9ca9-c45011a74085","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"bca3d5b2-7581-4ef7-9dcd-717c07e58a37","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"5afc8ee2-5ac1-41d0-bfd1-c63896066436","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"7fe80d1c-ba57-44e6-9762-e73dcdafda6f","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"1aa37a05-4627-4214-87cd-76fe83c49175","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"507e9b21-e782-4b09-9b63-3d2760df71d1","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"7ba8c1de-b302-47ac-96a6-565afc211760","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"39bb7d6a-4c5e-414c-aed0-64d273917620","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"4f5d1e0d-f36c-496e-8124-9b1409fe8c16","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"bdebe67e-88f5-42fd-a136-3ed5de7616d5","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"a4f8cdd2-d227-4e68-a571-f3ef166f7791","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"6b2a327a-4b84-47c0-a198-66693c127e5e","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"7e348a07-8c0a-40a9-8c9c-31ae19a16d4a","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"295a6f8d-d595-4c85-9e47-807f5b213eea","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"e8c76f90-937a-46a9-bec0-79e52ad192d3","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"98e14a61-8eb9-4e57-891a-6e7a72f323a6","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"6c1fc9cc-183b-4d6e-821d-28078d8d9c0e","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"a06d03a8-bdb5-4dc2-9adf-fcca25054cff","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"9924fb9c-01f2-4a7d-9090-111ea5fd30c3","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"dbf732af-f336-46b1-b024-c40cc494f386","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"13178b1f-5f48-437f-bf46-0d3a2bb1d66f","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"db96419b-c74e-477a-aa95-c2dcf087a26a","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"55a27cc3-ebca-45f8-bc35-ecb5922d7b47","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"3e4f9365-73fc-4e78-991b-83354799e0cd","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"c431beb0-7fae-40f8-a677-42f1d41979a6","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"adf8ee10-d601-4f6a-8b4f-cf8fd88ac49d","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"f73ce69e-64a3-4fb4-b987-e5b658a2df8c","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"745a516d-04b5-40b1-b1fc-8a480da8cd02","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"0c786098-0345-44f4-b00e-b6d1200bbdab","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"9782498e-fa20-4f9a-903d-b26ab08ac566","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"ef271db2-c7e8-4f72-ae2e-18cee424bd9e","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"179671c9-d904-45b0-847b-3143b5c1a236","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"053ff918-3ca7-4d2a-ac7e-5be917e0ea49","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"d11a8114-bb97-4cf9-a69a-45f753813ab4","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"5dc1fc19-95a9-49b7-837e-7e7c501a8d10","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"b405908e-b5f7-42b3-a933-b27d5a6f7a45","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"03552822-72e8-43ab-b6ce-5b7f721d1335","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"a328f42a-433a-4926-a292-e96deb74c502","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"a03f0655-4314-492e-87a3-e0d17f316ed8","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"4c39beef-48ed-4e7f-9f5b-42877de47291","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"7c77eee5-c1bd-4c10-ba9d-4237640ed649","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"17c8bb9b-6f96-4847-9c8a-bf06d86a93d8","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"9d2f0e1e-ec1c-4665-881e-47586e6f8145","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"abeb8619-b6e3-4666-ac55-4a0fac86d3c0","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"7fdb8380-8c74-4e6b-b538-5dd3add00975","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"502c068b-f56b-49af-afa4-ede550f5aa12","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"19d217c2-1377-4dd2-8f5f-590bd5f94fa1","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"6f3e8e83-9651-49db-baa0-62591d568b19","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"4a3b6318-1a85-4bbc-846e-0ec03e13d04b","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"739f858b-7ebc-44d5-a52e-ea957e290186","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"00de6f7d-273a-413b-8722-52e744d7ce16","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"ca290a8d-a68e-4a7e-8c53-5c4f84cc33bf","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"311fcbde-e0db-49c8-a483-a7ccbf6e1f14","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"785285d9-4843-42d5-b771-4b35bdae94c1","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"69b2c551-7d93-45c3-bda8-373e2c154091","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"f86dad72-8598-453e-987a-079ff7bb52f6","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"a8dbc754-2106-4bf1-bc35-d37a3ff3e6ab","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"4940f898-506f-42bd-9f6d-e5142d8e209f","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"d5b395f2-0bff-4781-9ed1-902393b56bbb","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"0adcd715-cf65-4f60-b0f0-1c4105f704b1","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"c70e6174-16f0-49cb-a9b8-146a08d74141","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"07cd9b1a-cd21-4309-9ee7-8d14f6e39f36","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"40976405-b0e4-4453-83ad-312eb05b5d81","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"460786e2-97db-4b7a-b7a7-35a80723f780","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"d22cac38-c5c0-4c94-bb46-e5c86098d252","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"e9a97fe7-07b4-4313-86df-c1b765d00943","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"462bf17f-0692-4b44-898f-88ed29dbf02b","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"d448d474-c77e-4828-a32d-ee88629ea9aa","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"ec90d652-c24b-4fdb-95f2-35015f64943e","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"da13464e-194b-446b-8c92-53f995746bf2","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"4529c57f-2a14-466d-a472-ef34431de4ba","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"c386ff4f-8b7c-4fd6-9e22-376a2f37b7dc","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"52a73582-60b0-464f-b99c-f34a817dba38","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"fcf944bf-c7e3-49c3-8571-20a622540e3d","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"25808b74-e11b-4f08-8203-12f737d0de4e","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"e144d0d2-ecad-432b-8369-af537bf3b468","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"9e1d933a-072d-44d1-b2da-6c36e08abb4e","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"14d3c746-d682-4f63-b9ca-fad3f0671d08","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"c4f392f4-58ff-4230-9f81-30d20e5bd5bf","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"964c4dd9-923f-467c-b55e-1782993ed8f3","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"ad0c85a9-685e-48a4-9b58-8236270997b2","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"8d8e91f2-3717-413a-b3c3-f08c0eee7f4f","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"ca7c973f-36b2-4b9f-b966-2f4f82dfc8c7","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"40f0488b-ce75-4cb0-a60e-de6f37e16e02","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"71b280df-47c9-460f-8245-6d99939a4c34","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"045665a7-b0e7-426f-9450-c596e0f8ddd3","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"e9d8581d-7090-430e-9643-2b0ac9acc940","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"3c4368c1-0e7f-4cb4-ad21-f93577daa04a","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"04c5ee36-76c9-4526-b87f-284ec1ff60fa","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"22ec45d1-bca4-4883-976f-3d7cd639b86f","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"7d0a73d6-68aa-4c01-b078-ec31511b4870","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"63833a66-8871-43ac-801d-2478d7b88f7d","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"eb9765b3-6cc3-4406-962f-d0edd3fcb864","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"9a1595a0-1386-4d2b-9df2-0909c44e82ce","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"1b7f89a9-4179-49d6-93b3-1d6987098d60","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"7bb5539f-cbad-4335-bc72-b1914c2723d5","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"17adde1e-cc6f-4b4b-8b10-3ca33a101324","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"05b0326e-746f-4325-b451-79cd56a34a57","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"0e5e57b5-bbc5-4c03-a469-d65db00e0ece","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"84aff94f-02fc-44cd-8755-12114cde2eab","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"5e1ff865-1952-4300-b231-06fbdfbb3f6b","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"7d900ac1-4923-43ca-bbeb-2c4b010a4d7c","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"485b16c8-68bd-42c3-b1cf-776bb6f5eb89","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"37f2bc78-5f22-4bfd-9d44-aab80aaf55e2","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"d6830162-5ed0-4069-ac78-9b5ff57e9e52","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"d07ee60c-77ed-4e38-a0db-00f255d88dfa","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"0e803001-e16d-4772-bc6d-74b910b67c67","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"8cc1eac8-d64d-4b89-9660-4ee8b82ade12","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"7263cf32-83de-4d65-8a98-df4e29b8772d","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"12808d4a-97b9-4f1d-92b8-45f63d80e771","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"8f60844e-2b8f-440f-bff0-3d8dcd5f0297","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"9cb39dad-1809-4dce-ae30-5b3a348bcb86","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"e04fd27f-9358-403b-af5d-a735f2c26b1f","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"7af53240-623b-4506-b6b4-4a49890bc6ea","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"2c27dbd9-543c-483c-bd0b-81454521c1d9","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"93045c2d-5e07-4c13-adf1-614485e98acc","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"2a3f523f-8f99-42a2-ad0f-29d9c113810c","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"c3848151-965e-4d2d-a22f-932cefd2c0c9","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"767854d0-f578-4061-a357-4c8126b6d5bc","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"7f59435d-d769-458e-ae94-e67a4eb2b956","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"c162d373-4f47-45dd-947e-72c081dc7bdd","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"413a60b5-a345-4b8a-a27b-b9caff7b0a97","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"fa0e4ef2-dd2d-4a9e-b9c2-7533f05de7ed","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"863643b7-9ea8-4099-8a3a-85f02886aaa4","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"c07809c4-4dd9-405a-b26f-7b2973bd060d","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"0b46c4fb-79a0-491e-aa16-92555d393dda","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"b6cc8989-5978-4a84-8fef-449e41aece09","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"e54d7445-549e-4c6c-a112-0963e2a29503","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"eeaf3f5b-f077-4647-9e8d-9cf0a6cbd26d","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"2a29c5ac-10b9-490d-99dc-8eec3a59e173","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"252b14ef-b3b8-4a86-9751-4c14e9241f00","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"daa650b0-f4e9-471c-8450-1104c5b39ead","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"c2fa4863-45c6-4b92-ade4-f4eb20cfad1f","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"774c7ceb-0f2a-499f-a4d6-9f53a6c53af8","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"0e098f46-30e4-4f7c-b5a7-c2c37c829432","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"e1aab6c6-cb68-4f84-838f-99df672231b7","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"c24258e6-a1b6-4291-9d74-2bd28a4e6d36","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"9196ae0a-c95d-472f-b4d5-dc3eda0136ef","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"2d4aa895-de94-4ad4-a961-2c92249b24c7","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"1c96c053-9dc0-40e8-81bf-39babce986b4","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"61b633fb-97f6-4ff9-9bba-f6a4b4a5a49a","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"d3a984d4-693a-43e3-8083-3ceb7eef4aba","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"6ccfb433-1115-4cd1-9ad9-2f4e73ef9a79","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"38aff444-8748-4676-91e0-7ad82b95f7ed","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"e7114813-6d33-4b8a-b55e-b168dc391137","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"5ad7accb-bc3d-4ae6-9493-404e3b1551a6","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"65a46f5f-4daa-4fa4-8bf7-18e70116ae1c","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"14aec695-6c6a-4a6f-a724-8152fc790d1b","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"426292b9-6ffa-4d34-8c96-65497b9d776f","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"7a713738-0e31-4731-9e2c-3e1bfc6b799a","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"f40ca54a-d3e4-4749-b666-be907578ffc5","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"06af19d1-81c1-42e4-9bf6-1c56c285ae19","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"5121558f-cd93-4832-ab6b-2ec20ca769fe","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"daad1a72-76f3-4e1d-b906-c3d35af31d4a","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"d1171c12-c25e-49af-9439-23e2d2b7719f","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"845530df-73b7-4f45-8b05-8ed068a6ecae","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"39e51d0f-b957-431d-9773-3a76c6187441","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"b4688cee-782a-43f3-9c11-e79ad0976c7f","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"40158082-557c-4267-af05-a15145354f35","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"dd6b380f-23b5-48bb-aef8-c3560c2aab8a","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"6b966bbf-3aab-4dc3-a345-b18e5a46fdf9","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"b65d6dc1-5af3-4d95-b554-bf344bd897e0","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"c5085502-4f3b-4969-a1d9-3a16652ff369","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"5e79ed41-b217-45b4-9c31-e012f33abc80","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"0eca2261-b6ee-4e72-b7e8-748202433cf0","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"a6dc8479-587b-4b70-abbd-0db889cd32d1","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"672a4934-6829-432f-9862-24f0722e2595","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"0f98810a-a01e-41ea-84d6-01c59685ee87","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"1019bd41-e832-4d29-b8c1-5732f4d8b506","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"52f947e9-36d2-4c7e-af02-d2032e929832","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"7a32b91e-1112-4b3d-b6f8-24e3ec4a8f25","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0}]}');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES
 ('195333c1-f93d-4354-a4dc-a41f08b7b20c', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Test First Name 2', 'Test Last Name 2', 'test2@mmp.guru', NOW(), 3);
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
 ('655a660f-9be0-4d35-9fa3-ca79c0d21c08', 'b222aa15-715f-4752-923d-8f33ee8a1736', '195333c1-f93d-4354-a4dc-a41f08b7b20c', NOW(), '{"id":"655a660f-9be0-4d35-9fa3-ca79c0d21c08","groupRatingItemResponses":[{"id":"9872d47f-ced1-49b2-8f00-418799aae71b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"eb00811e-6ab7-4aa7-936c-4b9ca4c2e058","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"157544ed-33aa-446f-80e3-442be650e4b4","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"58a9076c-d1fa-4636-9b24-5e5bee673a4c","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"368a620a-3b2b-4794-9946-0d6b9a153489","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"3312f6db-3151-47d6-94e1-69b48efe0f09","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"d3274146-596b-40cc-8ffa-08b2d53e8a61","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"32747323-cb04-4299-80a5-22264c864240","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"058519d8-48dd-484d-a75e-4b2288527507","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"3673a275-6848-4113-831b-0fa95244e29b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"d07042a8-9bfa-42e6-b059-38d44422732d","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"a56b93c6-4b2c-418a-b3e7-74ad6ca5a923","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"1549818f-1793-430e-8111-443436b7203f","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"ea51f87f-581d-44fd-ad01-959145291e31","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"cc0c265f-a518-472e-b256-f5046329bc0f","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"f78ce30a-6e02-4f8b-8780-ff9563dc779b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"63c72e08-7a60-44fe-b669-33d630f13ba5","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"de301dfa-f708-4803-9ce6-2088ed181cf6","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"4a5cf861-4cf2-415c-82f2-6a69eb675594","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"35d7d153-0df6-423a-afdb-584a696b3190","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"2bc59cc0-7340-4898-bfbc-391d447361b7","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"4bdd2566-5b3d-47a0-886b-b4d977f11eba","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"22c9ff2e-e62f-4e13-a6f0-de98d9d089b6","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"a1238c2b-2095-4746-8691-603219aa36e2","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"cb5c009c-21c3-4e46-b75d-b57f6333c07e","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"3439c241-81fc-43a6-9e1c-1973d8751f49","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"4af2efdb-92f8-4749-8e25-c0f1c1789d0a","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"e8fcb4ea-90e7-4f04-aef8-fa5dcae76a9b","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"8a8de522-68e0-4826-8e97-e19332a31f22","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"28433f1c-9019-441d-98d3-aea13e2a31e6","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"d43bd124-2cce-4788-98a4-994d3c9cb5a5","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"8b55d7c5-3737-4587-b874-d573cc7dce98","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"d4387d32-5b95-46a4-b47a-89e3e5b9b613","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"a388da1e-b521-4524-9219-1eb668992a86","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"e10ea7d0-34b6-441e-a0c9-2f6a759c1bab","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"49d285dd-04cc-4849-ab33-2f1fb6730b9c","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"4d41f9d4-d236-4ad5-b674-c911eb0d932d","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"99e57996-adec-4881-ad10-188bccd1878a","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"608fec7d-7c3b-491d-a89e-f1c7a6ccc776","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"9eb4eb79-0074-4a55-bf3a-f5e58dad6e3c","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"8ddadad2-c334-4b06-8a79-6d498ad3e062","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"04821663-e37e-4a70-8952-63816850e280","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"9047464a-083b-406c-b995-d464693aea33","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"5de81c75-434a-415c-a1be-fbf1678391e8","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"af84c2f0-d109-4ce6-8ce2-1cb474508f39","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"10330a37-133f-4f44-aa81-05481bd7edf2","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"8f5f9d4c-cf3c-4e27-b168-3bca3bcc916a","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"d3963055-ba7a-4e45-b2a9-65ba7f0bc220","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"40b6fc5c-6aa8-4e64-bfca-f2dac2befc5e","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"1d4c564a-7237-401a-ae34-7bbdd2c39000","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"e3822a98-d4af-49f1-b825-03c0611218b6","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"16619047-d936-400f-ad6a-1b2156e86e12","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"d81c8eda-93be-4a70-b6f8-16483edab257","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"04313f7e-792b-4adc-ae85-002ef095cc0d","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"bd28531f-bc30-4681-b957-49adf4be0089","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"04e98317-eae3-411b-a43f-d8c0d49f82f0","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"8b67cfbd-685c-4f01-be1f-1c734d78524e","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"ba43c145-b379-4c21-8957-96d15b1f1060","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"1545b583-2342-45ba-be1a-fc34581c970a","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"f65b7679-7716-4a4a-89d9-2d7206e352b9","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"b5e2f9cd-c5d3-45c2-ade3-ffda98947ef1","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"3bb4d680-5199-4776-8074-a5b3d51e8a05","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"cbeb78b6-e7d1-4655-bc65-fb2228a4976d","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"dd9b0c1a-47f7-4523-869b-079204bff641","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"3ddfe703-9827-4ee2-95dc-4f64f2d4812a","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"f4286bda-361f-4f0e-8e1f-d367e96f055d","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"56cb92ef-e9fd-4aa2-8050-f181bdfa71a5","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"d24859dc-ab86-407e-80a8-a5c47ea748fb","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"bccd0294-0c87-4128-935d-32a71794318a","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"ccf6cffb-2c04-4452-916c-d76b593fa5d6","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"74ed7e95-3113-4d33-a79d-7f5e08974c2b","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"8938fcc8-4b62-48e8-bca8-02733fa36a42","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"8c43e81d-0b72-4252-835d-a4dd4ec1a622","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"f17730a2-b70c-4adc-93d4-e71999e0c05d","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"f4a8f5a1-a2c5-494c-b753-74fa454da091","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"c09dbc6e-ef99-41bf-b63a-46d2f1157453","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"a29492ea-348d-4dbf-84c4-34e51047d25d","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"a8b6c817-d9ea-484f-bd1e-2857f1819c13","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"53e4b22d-9200-4d58-b87d-76fb1c24085e","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"23716362-626c-4a53-80ff-18a44fbcfd22","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"beee45ae-8d3c-4596-b83b-05e27c920913","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"4f38d6dc-aaab-4eb5-84c5-252fc2c6ffa9","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"b870a943-eb67-45e0-8a59-2b0bfe46b3da","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"5f92d099-cbc4-4cc6-80aa-bcb8284efa0f","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"111fc794-ec1b-4720-82d6-17d7c7f52ea0","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"eecac7d1-f543-4498-89b4-666d11f34ecd","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"038fb1fe-00d1-4cbc-8559-53e091d6b90e","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"8d7e3d29-48b2-4ee8-a815-68f496c028ab","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"b19063ca-0756-4445-a517-14d61993b230","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"3a8d50be-1ccc-44f6-accc-d62ed5a3f356","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"bf69e341-4924-4185-9c48-a4c6f03e5b77","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"1eb0187c-a105-457e-9fd8-132fa2b9a07a","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"4dabe7c2-e6f0-4781-8f6c-fc4ad832db66","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"c9d7243d-7a86-4e6a-a631-1bcb1c20cd93","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"088cac55-3c39-49ad-ae74-551341a9cdda","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"1098b8d2-eb15-419e-97ac-8d61e00353fc","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"b3642d44-fb27-40cc-8eb7-5d18da8443e6","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"ff4e4b86-b3b1-4f63-95ba-6c33c20cc7df","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"17d205eb-f7cf-432e-9a46-0391438b3ea2","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"b3551175-0edf-486c-952a-61ba14711a0f","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"6dbeffd8-aca6-4b9e-82da-10c518683f55","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"2c647dfb-ea55-4acb-aa78-d832de750879","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"487201a7-d141-4659-ab5b-beb1c1af736d","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"83b0a061-9761-4283-9834-302592233750","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"9a761469-56ac-45d7-8233-b2ee6ed607a6","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"7c52df76-cc49-4cb7-9f8f-11ebffe80e09","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"886232bd-080e-404d-a409-78ce369cd5ec","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"a5193a17-48be-473e-81f1-9aa7f580cfe2","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"2543f88e-35b3-4196-a60b-1abd6bdba107","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"062df4aa-5b4b-424d-aded-d39321d5f026","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"a770906e-254a-47d8-b8bc-2ea9ae07c68a","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"66573619-77f7-46a1-8391-6b8c0819d4ad","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"af76354c-a782-4233-99b9-5aa540f74ce0","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"a3480f94-ea61-4997-94f9-46099e14ec6f","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"2ac179d8-bc4b-4c5b-a198-4affda5ab624","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"91948f21-cfb7-4b83-a0e1-d27bfc25269d","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"c06b2fb8-308f-4ad7-adf6-cf0655cf4204","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"d30a2f86-b772-4219-b944-379888cfc7d0","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"f5708e22-d762-46cc-82fc-bc5a97acadb1","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"1ca723f9-baa0-459f-a3af-b9d98d42615f","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"7a1d636d-c80a-4d54-9954-5bbd7bc1d27c","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"6963361c-1442-4344-a960-f0d1111f9c36","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"9f469ead-0816-4e0b-b9a2-2c1ba100ab94","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"c94fa383-47f2-4b72-9e0e-13102ba12119","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"32a6a142-b3d3-45ec-a3a1-cab7f3006be9","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"e6a1ec52-042a-476b-816f-eba306de57fd","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"e593b0a0-1af3-413c-9d36-fe0e2d2bff3b","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"e3eb58e8-bbe2-431b-b55f-012ed3fff556","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"d2634eff-e215-41e3-be38-427b85512d59","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"0c0a84ce-f3a2-4f82-9c37-fd034df07b8a","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"35e48a9d-b3fd-4a75-b937-256381f87131","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"0d46b0d9-c356-4dc2-bfea-d02a180b4d42","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"145f77cc-64cc-4962-90a2-9c6e79f6fca0","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"6404d174-9378-4402-b566-9a0711d079fe","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"79727429-35c2-4875-967d-f1ca95b2bc18","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"c54c3cda-5289-4d85-8be0-59c3966adf28","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"95148465-cac1-4b62-b162-2b93557e8150","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"5f99e485-cb09-47e0-bf4f-c8bb8e0ff659","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"b0f14836-6034-48c9-a8b0-fd91b0a70bcc","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"2fa00a00-d44f-4bcc-adea-e863d2a8fb6e","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"393bc27b-2abc-463c-a4fb-889598544091","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"c9923dcd-1b40-4bc6-94f7-6cb3e488acb1","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"c0c8f484-1ff2-4158-b126-2340c96a70bc","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"0d77a2e1-9f99-4f8a-bbf5-08d1dd053e3d","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"71ccbee7-833c-4315-adbe-778c5fa2bb42","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"372e6ff4-cb0d-4e29-bc6e-f332fa0b659c","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"894dae5f-5334-4b63-9b00-40eb2dfe9458","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"a928f4c6-0f90-46ca-8f58-fac040b2dc60","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"e3f28110-65fd-47f1-8c2c-a908245238b7","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"59a2d339-4545-40c2-8867-ab1a44e4c885","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"3e1b029c-87cc-4300-aa64-d67a43db6b18","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"ce9dfe91-facd-4a2f-828c-51d84556469d","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"f43988fc-48f9-4c6e-b7d4-89936418c75e","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"d15a31c6-d629-43ca-9980-563578fe21d0","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"e6266ccd-2a19-4e32-832f-e5414b004223","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"5efc9639-d89e-40e8-ba5c-2426bd5c9e49","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"2d3433c6-9c4a-4902-a12a-41f3c0531a93","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"6fbf8dfa-d087-4cf3-8a24-701cbc03600b","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"c6f3e4c3-82e3-4506-9f77-0a67d9d7f097","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"73a0b315-c079-4ed5-b1a7-e0aa5c466d2d","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"af02ef10-4dfc-4398-84d4-f9fc4707b65c","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"46508077-5c4d-426a-9959-eec9856ce765","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"0d2da3b4-11f5-4b73-a009-f5628096da27","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"7e0d2b5b-00c6-474e-af99-25c65262dcc1","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"4af10da8-29d0-47ba-a775-b4b0485961bc","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"2be3c655-aac4-4b10-ae71-299b0a874875","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"78f7b171-6ddd-4148-83a1-e838bf1c14bf","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"8f8f4079-6ff1-4a8c-ac1b-3fdb37e9c7a0","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"671465c2-a0fe-4b8f-82cb-d5a9d26261eb","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"e356cbad-c2f2-410a-b32e-007c4095f327","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"4f6ce187-1c41-414d-90c0-b62ee33c7af9","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"43f8b831-8cdf-4404-8aef-a544eaf54f7a","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"536244f4-fd31-4f2c-8189-e5a6c23fb07c","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"dd7c8312-00b5-4ba6-8b22-dd80774043fd","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"db8e103c-b2e0-4e8b-abfb-1018bc1fc9af","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"805d9e57-6138-4c92-902b-80ad1b85bc27","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"7c104c08-79fc-48a5-88fb-1d1e8da018e2","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"fb0d3989-6c96-4025-8f1e-0dcb587d6145","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"6266050c-ddae-447f-9e46-e8ffe2e6d592","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"75bdb6f3-8d2d-4069-b28f-78bda3447372","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"a3266b14-0d36-494b-8968-b672f869b94e","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"e0adbe6c-fa25-4fab-85fc-a4b5b2b0a174","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"5bfc79d8-928c-42ac-9c95-b140ef0b5e4c","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"b42b7176-5467-4eab-bd97-0c6c07d8d1d4","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"c9f0cd1c-1780-477f-9eec-35584c71656b","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"20106aac-59cc-452a-8e10-09ba8f2a825f","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"2750e8f3-f59d-431e-ad7d-474aa5c0a017","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"36d9ed91-349a-481a-9cb7-371456103e81","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"8b1a4b1e-cb8b-44af-8fe3-b7f617214e84","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"65a2c1b4-54d3-415f-bef1-dc90e876cfa7","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"529c861f-8475-4c7f-ae44-8171304bc19e","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"9b8ef667-b0f6-42a8-837e-9bfda216503d","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"6012f3a2-0009-4f45-80e0-04c34a08e171","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"74b53e6f-3542-4cc8-860e-bd9614da227d","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"06766aea-26a5-41b2-906d-f6e094ef405b","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"f0fec962-a393-44e7-9708-749c47ab4aa9","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"bd3647a1-c62e-4455-bf7b-f4b1af13c873","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"5b2e63e5-dada-48de-8ba4-db12faba04ce","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"ef685235-6a6c-4850-98bd-78163a6918c0","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"e3656710-20b0-425c-852f-6e6d6e53be82","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"d547f6fa-f8ad-4c73-846d-8d83cd55d208","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"37e7a3a9-5ef0-46b7-943d-467c91f67dc6","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"7da41f16-e67c-4187-9872-da39543859f6","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"2e9a18d0-f456-4bf6-b37a-6b057ab5b7d8","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"f55a91e8-f510-4516-9a01-739d955feb0c","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"b7b38f2e-2536-4e51-a876-72e5ec555c0a","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"5cb74403-db79-4c76-8780-933bc6c36fd3","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"5c1ab989-11d4-4707-88c9-55a713f021bc","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"7dce7ab9-6000-4aa8-9c54-dc02ed9376aa","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"f6268a37-a814-44ba-a51d-576209c2a5d8","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1}]}');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES
 ('4b3cc9a5-0a4b-4c1b-846a-8f1033b38537', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Test First Name 3', 'Test Last Name 3', 'test3@mmp.guru', NOW(), 3);
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
 ('911e0990-ebd1-4055-98da-ef7b7da6a365', 'b222aa15-715f-4752-923d-8f33ee8a1736', '4b3cc9a5-0a4b-4c1b-846a-8f1033b38537', NOW(), '{"id":"911e0990-ebd1-4055-98da-ef7b7da6a365","groupRatingItemResponses":[{"id":"aed1aa8f-1458-4170-a31b-d54afc57236b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"e849f1f8-9719-488e-8e4a-61d840167deb","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"2f214424-48d8-42cd-8e3a-16f711b81be3","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"b1d09d18-4f85-4ab8-96e3-4342ddc2bc5e","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"324094d8-64bf-42a2-92a7-1298e39ad383","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"3950c65c-9e75-477d-9f0e-2360e898b726","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"4ac36e78-27e3-4945-8f71-ed1e36001570","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"02d0bc79-c771-48ec-9f59-e56020998d04","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"2d4dc423-12b9-4660-bbd2-13a718936472","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"63867f24-ff7b-4073-a5e2-092201ad54a3","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"5a5e3bec-2cc6-4200-bf24-a3f0aba64953","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"fdc79795-b3c2-4823-9d87-bb101bf4374b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"92164394-766e-4fde-91f5-9d887cacc0f2","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"9bc6f49a-e452-4256-a4df-d77af3a92813","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"257325fa-e024-41ce-b7c3-415c5836f88b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"40cdd053-be49-49bf-a151-47f2326fefaa","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"8be7e37b-c9c0-4d11-ad31-53710b26c449","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"3669e234-a552-481f-9919-9b348c555b81","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"2266c647-3187-4abb-bc61-3f017c98d0cd","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"c933a1a6-9e53-4ef8-ac1b-b15eec7cb182","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"2922164b-c740-41a6-acb9-bdcda1b15500","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"39e4f968-5ba9-49ef-b99b-8f3f20e940a5","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"eee307b9-5e16-43e3-a15d-d0f7ee49e05d","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"28455a46-da45-4dcd-9db1-3df1a5b938cb","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"4042ca20-fde9-4316-b46a-fcbb14767dc6","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"5d62e063-b176-4c73-899c-66f194c22246","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"f925a645-9522-4225-94f7-f89e370087e7","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"99b57d5f-1042-47ef-bb42-e605249e4b14","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"6a504300-dc76-4faf-baae-4251ae249fce","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"9f54546f-b48f-4d70-bd3f-55937cab65d6","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"a870785f-aca2-4a9e-9208-cc8c9c76ddf8","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"8dffdb8f-fe46-4f04-84ad-e7de22d55616","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"1f03bff1-2186-4eaa-be96-a5fa7ff80565","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"303f0b2f-d626-46dd-bcea-a0ca96f07080","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"ecd67348-ea9e-4ebd-a07c-fabc63e311df","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"96a410a3-1175-4450-b103-835059ee1f27","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"86e55915-b2eb-4f42-970c-1e31f7dfa2ac","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"757a591d-a267-4626-a01c-9b8808b3fce1","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"6e3d178d-f365-4802-9f9f-16978096e5d4","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"72bd5d00-4b10-4711-af98-5dd9c1c9d78d","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"93f2ff3f-4d2e-430b-bb81-a1e234ecb573","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"c8c9c5a9-22fd-4c06-bbe5-b3cdb664c6e9","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"70d05cf3-38bf-4bb9-84b0-cc85b7fbbf39","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"bec23a11-168e-4541-b6fe-13b7831dae70","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"117cf7e2-cdc8-4baa-ba5b-d15e21eab5dd","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"f665ed20-235f-4b80-863e-25617b39976f","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"91056b71-c1e8-4ac9-b442-9abc73aeca28","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"3622a1cd-cd4d-4d18-bd53-d066895bbf2e","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"d1176948-9bc5-4912-98c0-773236cc9ad2","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"4a5adf3e-2468-4f5a-95d3-3bdfc5fbd962","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"9cc42baf-e2f5-4a2b-9a23-8ea18b81e3f1","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"797c9f22-f383-4c1f-ab7a-cd654bf1dbbe","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"4a7c5497-4f8d-47c1-b4ac-0d0b2f5a3226","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"488ee296-9fb8-4b41-96fb-132fe0c6fc16","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"90ff575c-2fb1-4b6d-bdc3-e45bbff6cb73","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"f6931b75-756a-42e3-96bf-27e682f6dc9f","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"ebd10cf5-d8b6-40e8-b0ae-5fb7cfd4ac63","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"b461c5b2-63ca-4321-a27e-a05eec185ca5","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"b45ee874-e70e-48e8-8aef-77ccbaf4b233","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"78dea1c9-ac3a-4224-97fb-472b16496058","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"e77fa5cd-71da-4650-8868-5bbb5cec47a6","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"89450134-3628-4801-b84d-9659c896ff7c","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"7ae086c7-ed99-4dc8-a469-f2246396c259","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"a2042746-0124-477a-9f37-b9b880143374","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"700a406a-d0ef-4593-8173-fab6f5326599","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"88ee5b68-5ccb-43c1-aa64-04fe0539d2c3","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"6b5ac62a-fc10-4a22-9a9a-0f6555f402e5","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"719f61d9-64de-41fa-b6e1-8f05ffd69b61","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"5e23eb6d-0cd2-4cdc-a33d-42d014781103","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"8e51d181-57b4-4e56-b70d-b658d0c7c631","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"413919c4-c2e2-44c8-97c3-4aa8b79585ba","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"82e1097c-3b8b-4487-9a32-1752f2bd8770","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"4ab34aaa-a60e-4415-a14b-59829b250354","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"1885c7e0-0820-4ba5-ab75-38152297bcbe","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"d2bc1202-e1bb-44bc-adbf-b9e01156f22d","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"12cf7f59-bb23-4c08-9bdb-6ef2526c7835","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"7abf5fac-2d45-4bc6-8574-8d67a204d2fd","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"c15ecc36-11bb-4e07-b979-10e262b11aa5","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"1f5679d5-b35d-47e0-ae4f-d0f89f42a3bb","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"f316b415-da5f-417d-81ba-7cd3d249e91f","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"5b8a0a88-032c-451e-a68d-1c896118bb49","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"04632f0c-58f4-4f45-9249-94adfb4b115f","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"69d22d09-e795-4ee5-b1b0-6d28d0276099","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"513d2690-31f0-457d-b074-7f68a621caf7","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"0926a2a1-559b-476c-bc10-bd5f4f52de20","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"f7b7a627-9f5a-49f2-b294-fb91022c9255","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"8ad9725b-11a2-4218-8a04-136780c12478","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"19836154-e5fd-4aa5-ad4a-d0b8ea0803dc","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"def43a24-fc39-4057-a859-268e23d4a8c3","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"dbd05ef6-7f5c-424a-93ff-b37cd9aff334","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"4e668768-caa1-4d9a-81e8-f9da03a2fa11","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"3fdd60a7-fc04-48e7-bbbd-b57affef1ac4","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"ee4e422f-c8d8-4731-86a7-44c759e62ab1","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"c7945955-2046-4c80-ba47-275b4b6cf2ba","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"63497563-8633-4023-8d1f-a2e1c46ea575","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"f718292c-d6ba-4bd0-b61a-d85fe964224f","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"8da219f0-b5be-47d7-bcb3-e49d72fa460b","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"4b3a75ee-e83b-4d4c-bf3e-1fc33ab5c7a7","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"24bab5cb-17d3-43b6-b9e4-4aa97487eb3b","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"629b4bdd-c567-43a5-ab90-d36ae1ee075f","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"66f675d1-c72d-4054-9172-91e7922dae20","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"51295102-ad57-49d5-823d-86ffb4bfb7e7","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"46c09b94-2e6b-47ba-b43b-31b17fcfc073","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"9ea3e3e7-9c92-452b-8605-20d4f75019f3","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"9fb4fd5c-fb03-4ff4-9bac-00be7751b956","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"01e6f9ea-f582-4435-aee1-572026c5d08c","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"f242827e-e2db-4646-bc38-84ea15ef203a","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"e97f3e24-dddc-4b7a-9961-8889a4bc70bb","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"d2f19940-75ad-4125-997a-08c9636de037","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"eb656980-3db6-4537-ab8d-be650bc7cc7b","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"3f2b05bd-353a-4b3a-b352-e0e9232ffaa0","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"9a52f5b2-b8cd-4e10-8c87-f7de6a6adfc8","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"c43a3c6e-0307-4f2a-8013-1146f668abcd","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"e43bac0b-5f4f-47fb-9a6b-f77585433afa","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"dbbdbfaa-f2b7-462c-a235-ef6012c28c9f","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"c3fd2236-a08e-42af-8c76-9491a39288d1","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"42e760a8-4608-4335-9621-6f121f9fd617","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"6bae6460-8507-46fd-a73f-990d19fa673b","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"68ef6bd7-2fa2-45cb-b164-c8eaa6088969","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"03d20fc1-2c08-47d9-90e3-7c4c7339f1a7","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"5c8be35a-4ce9-4924-a29e-0a7e70e2f334","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"6235aec9-091d-4b1b-aced-89eaa3072d1a","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"3b26e8a1-b535-4385-947f-7c49d3a7a656","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"042a4252-b7fd-4d2a-9610-5d244e94190e","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"03f9ab92-2a04-48c7-ab00-32e78ea491f1","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"605199ae-7e48-44d3-a936-9935d7326ac7","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"612429e4-ef8b-4841-93ed-932928e14760","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"a90e136f-80d0-458f-9670-fa9ab44779e9","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"71b4c1fb-36bb-4575-bd98-48d6ad36393e","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"24453724-7124-4bc2-83e0-6cd3359671fe","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"f9470d4e-89bc-4a63-a8ab-23fdb842a161","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"463ece91-8e34-424d-ad31-0a6aa10fb576","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"776e06ad-6f0c-467a-a9f8-a2d786fe1045","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"edb01bf4-a2a4-4a18-971e-7628f1e398cd","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"f236319f-f038-4c2c-b1c2-0392a5401ea2","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"b4ebc0ee-ab89-42d5-95f1-fa43f4ca8cbf","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"b2e23ce0-27b4-4c50-8394-2672439292b4","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"990c17f7-8f54-4e26-8447-1c0809f37bb8","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"295d81db-eb6b-4fa6-a49d-7183d899fa54","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"f14f44d5-34b7-4b2a-b869-9f8e3ceea243","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"da9b17e9-43b8-4228-82df-a462243b6398","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"f143901a-d660-4a4b-a8b6-a7a2c661a10e","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"810aa7c0-7903-4ece-9181-44b96fcb3117","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"480478ec-028e-4602-b61c-6bd4c5adf8d1","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"1133c41d-e094-4563-8aec-cfb91dc5551a","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"ff6a90fa-e8c0-42ca-9c9a-ab48ed2c01b5","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"93fac7b9-d36a-4115-b8fb-2fc0153e7903","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"90508835-1f3e-49a1-b68f-cac042dc2450","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"3c7ad63a-0cc0-4b8c-9e23-ade78d282e13","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"d413cbca-91c4-4863-8fec-21008db3f907","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"0892bec4-bb6e-4966-9e1d-6fc5201a25cb","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"3d9e2cf0-168f-4c1c-9ff0-7dcff401f92b","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"f23aeea4-5475-4b51-be64-6e6a1d7fe67f","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"5c6d6d52-b828-46a1-8aa0-c05c5c3aa527","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"0cb4e522-c692-40cf-88c6-7225d56b4699","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"a27f3718-a75b-47e6-a295-80ea42df3e22","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"012089bb-be96-4018-b773-d4cb939f1ac2","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"28f1c128-c485-41a4-9394-4e74d97762d2","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"d1006f1b-6bb9-4af5-931b-588c7943ef83","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"f7482282-d558-4d71-9454-4d73b9adc551","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"92c4db1f-86e4-4dbd-a65c-0176cdd69b78","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"065b0dcd-f526-44a4-bcc5-c88d51eb0330","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"fc7ce911-08c4-4017-b8a8-0be8e7e2babd","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"f951f64e-c41d-43d5-8454-c0ae6b9a0a4b","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"228ce565-11ac-4455-b6db-d9fb44cf776c","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"f307a89f-7017-4c2a-a3f2-801cd299133b","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"38d79fe8-959e-45a6-afec-fbac6b0f71f1","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"7bc11a9c-9251-4e01-8e99-077cca4c58ac","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"d454af9b-2904-4d94-b94a-9a4359395d95","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"a2a4633d-32db-4664-ba06-aeb97ca10604","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"85d6fee7-993b-4b13-a15f-10b2514abe98","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"82f84787-c07f-4982-8644-d3b1708ec417","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"d19be7cf-1918-48ee-bbeb-a03410c5202f","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"90568e41-fd04-4711-b517-f269f836ee25","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"e237fda6-11b0-444c-8832-941ae928d37e","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"6220b3bf-696d-444e-8f76-ef8efba68865","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"dd9fc932-5678-4b75-911a-3d19f75712a8","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"2c5fe748-eeaa-4c2f-ad33-4b676dcdac4b","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"db409515-6d2a-4d2a-88a4-0111f7151b07","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"49220020-30a6-43e6-b43a-1ea3487412e6","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"9313248f-64e6-482c-952b-81e56c9b10f3","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"802b2ffd-125d-4ede-bb48-c2fad3526e1d","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":1},{"id":"467c79fe-ad53-4f5f-ac41-d40f44a5a77d","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"d9eff3d7-2e59-49e8-a07a-7b0f2b419009","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"dc4823c6-0d30-410b-be2d-ba8ec3455054","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"732692ce-8eb0-45f7-ba4f-6fa2fc2728d8","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"78c5475d-962f-4d05-a3d3-1279b94acc23","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"226c42ff-9ec0-44bd-961e-b332e8e9fd72","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"2c71bcb1-99c1-4d6e-a510-576f8bc91b3d","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"e1e01a7a-e900-43a0-ac55-8803808d3091","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"6619c7ec-058a-4787-9fdc-17fc01780603","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"2842c103-ed78-4095-8919-c1cf8c5aa61d","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"ddd2d884-35e6-4fdb-9f99-4cc7803b9cb3","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"946e4ee1-dafd-4c35-8bb0-e712c07f03a2","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"fb296f60-a486-4dfc-8cf7-7a773fa18a53","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"6305fc4d-00d4-452d-aca9-fded9d5ff718","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"457520bb-c293-48fc-a7ea-77fd70dcf5e5","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"209e2b55-d94f-4900-8096-ce3dd716b3ac","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"90d81aee-dd29-4d94-b58e-a5bea4a4443e","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"a91d68c5-a04a-4676-ac90-cc0ebc948e36","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"13a7b694-c041-419b-9523-011aa363f7b3","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"91b8ee9d-b426-49b3-a9bd-196c9baa3625","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"85e8e2a8-72ab-4dfa-b2b3-e2a885ca0f7f","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"49094f3f-d94c-4bc1-ae9d-6cab43c38e94","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"7f804fa0-f3e2-4c52-9028-b3fa94d805b3","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"3746014b-e321-4c84-846c-823e9cf7a06c","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"023729c3-b9c6-494a-86b0-df9e781b6d3f","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"7e567964-717c-4d93-a964-7883dddc5767","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"a9d70a16-e9e7-4a48-89fc-6386f2309fd6","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"730db044-39c2-4f16-821f-8f891c6ddf70","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1}]}');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES
 ('12485757-7756-4af6-9bf8-914ba9d02200', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Test First Name 4', 'Test Last Name 4', 'test4@mmp.guru', NOW(), 3);
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
 ('3c98a47a-a4aa-4d24-9349-393c28407335', 'b222aa15-715f-4752-923d-8f33ee8a1736', '12485757-7756-4af6-9bf8-914ba9d02200', NOW(), '{"id":"3c98a47a-a4aa-4d24-9349-393c28407335","groupRatingItemResponses":[{"id":"8311acde-8e83-44ec-9083-e2cd913e753b","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"f93211be-cf4f-435e-8713-c4c3442bb3d9","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"a61609fb-6b46-4628-a3c0-3abe49d859a5","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"c4393317-fcfe-4e87-9d24-e545418e0bdf","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"fc61fe29-1b8f-46ea-b705-57292c82b884","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"4cac6333-786a-4aad-831a-4af995c55c38","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"9a0cacb4-ada0-4d35-9fc8-edbb0e958e8a","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"bca33cc9-0bb7-475e-af15-50791e873819","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"40ed0f47-c519-4d2e-87f5-f6ebc65b81ee","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"4cb3ba0f-17e2-405e-836e-c11aec11cbb2","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"41c9f826-cdd8-45f5-a096-624f28062974","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"9c8d741d-379a-4d56-853e-ea63d551e5cd","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"ba9d54bf-466f-4b3b-941f-94f9f2f6b50f","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"1ed345c0-055e-4f6b-b523-929682f5ad0e","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"c4fa0cdd-d268-46da-8a8e-53d3da33bb84","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"f45e8a70-455b-43c7-bdf4-e1a8f5f8f8d2","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"b33876ff-dd77-40aa-b137-fa6f96b0c9b4","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"56a7bd77-6eb4-4525-a2e6-7b335c56b61f","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"199d6294-8267-4a5d-92b9-5fc8927a1b20","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"7ff265e2-8399-48de-9329-c6340841c28f","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"172893b5-394b-40a3-a7f0-060dfae03245","groupRatingItemDefinitionId":"3b6df123-d1a6-449d-87bf-2e950357b353","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"3e6d36b0-3b38-4899-ab55-78b79ffc9cf5","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"ed787f41-bd39-4188-9b65-d83464707f41","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"bf1a7ddd-93f2-4607-8e68-56e00e5199a0","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"7ea42b94-c92e-47ac-af0a-b8ed423086b5","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"6d2f96ec-dca3-432a-b9ad-7f08913850b0","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"acab6d0b-5e30-4e8b-a8eb-4f76bd7eb3f1","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"fe42c37e-8b21-4f62-8ee4-7d04c6b8e372","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"beb0bf34-1b11-4953-9aff-201dd61f2879","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"636d831f-cb0d-4163-b8c1-2863d4b56e8d","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"b0d4a441-93df-418a-a0fd-df290a030bbf","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"b28fdebb-9401-45d1-a865-b05c4f0ee24f","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"512e2c05-231d-4af9-a6e5-b95c689adfba","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"95b79316-dd69-4284-8473-4888bd6c8196","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"424177a7-5407-4dfa-897a-a0583151880f","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"173c5b91-73e7-4074-b6b5-880a79f1fc98","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"2fae4620-b66a-4a48-bfee-dc9b649bc060","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"db91b2fa-e96d-4016-9331-ae48b1cc9500","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"35223e7e-f249-4344-85bd-aa5201c401e1","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"6a9a1d2c-a2b9-42a0-8c4d-32c190b96bda","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"e7abb3f7-815e-4189-9784-65303e251218","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"b9fbe94c-0c5f-434e-b620-1036b4073263","groupRatingItemDefinitionId":"fa22e7e1-5579-4904-aca2-d4c394bdac5b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"acf27cc6-19ae-40d2-8d87-c1e471d5a1dc","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"df61d290-07f3-42da-be26-79b00acdf5fd","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"80eb3ed6-7d68-465d-a901-54a3c9125a9b","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"842e8af4-c45f-418e-a64d-51558c88149c","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"575a4b68-4fbc-4508-aac9-fca422502e22","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":-1},{"id":"25da369d-7181-484e-91be-7546d69f7207","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"dbd7a916-81a7-475d-ab35-48b223fa9d84","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"f8682fea-e069-4896-b3cb-2df64c7cae43","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"a71371e3-3dc6-4aed-81ae-326971dc62d7","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"e59775b1-ced9-4b9e-a396-9efda5cc146a","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"bb8bf3fb-c946-4862-af53-a9d2729e80c6","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"b5f3b2b8-164b-4995-9542-e7082fa2b56b","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"b201c18a-696a-4775-a7ae-1d7d7127388a","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"2feb63c8-b190-4402-adaf-1cc58b8777c8","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"4b7bccab-71e2-43b0-ab73-4e8ae403de72","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"b2fe6714-0a00-4e18-a82d-d4b9349ebd29","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"2537817d-1da4-4938-8a91-0608daf0c3b7","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"4bc4bbfd-dbf4-4fe3-a662-3beea484fbc2","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"963aaa21-c363-4f99-8ca2-128b3e4e4bbe","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":-1},{"id":"612c482c-1c7f-4dcd-9e93-cc206dc45ba3","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"07d3c223-4fc0-4759-b567-1a66c6482f4c","groupRatingItemDefinitionId":"85af4470-f5f3-4d84-9b4f-50a66ac12345","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"48269ce8-a3d5-47af-ad28-b6ffc45a0c7b","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"2c9616e8-0b04-4547-bc7b-ea3ae2e27bbb","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"60b78383-0d44-47e8-b7e3-fbb432412dd6","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"bbfc21f0-9a9b-47d9-92ad-6e4497047b08","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"36c5b46a-7081-4c15-aee0-a2173afb6484","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"0db0c403-0b56-4e1d-8157-f6219998dff3","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"bfb84c20-7767-47f1-9e8f-f60639d77a82","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"03c2b3c2-b784-406a-8b3b-8ecdb3fbad55","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"8a3f8ae7-2965-446c-848e-03173c1a8e41","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"4c1baec4-918e-45d0-a349-50c31e18c5a2","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"8f48be8b-0986-4023-b3c3-cdf65c3c8b6d","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":0},{"id":"511d6675-a9e0-4c7b-9047-516e76b14474","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"96284104-b263-4b2b-bc92-4e7ee7e03285","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"55e6ebfd-a334-4de4-8668-2a35744676b9","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"a3b54e1e-3193-4f78-a35e-cb914313cfea","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"c7bf75dc-45a5-4222-a555-8c9f3883e69c","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"f1c3c75b-a8b9-4816-bb9b-8d49cc169988","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"a6062d21-6ce7-4222-acbe-aba1223a2637","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"64cda21e-44c3-456e-84e7-529784a5a92e","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"640884c0-6dfe-4352-8c53-5a869e757a4e","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"bbc35460-f881-45ce-8ceb-90b957358133","groupRatingItemDefinitionId":"7bf82ab8-9347-4e4f-95bd-12e170b2e063","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"d348e784-d5ab-4ae4-839a-690b0a914fa6","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"d2ce36e7-cbac-4171-9eab-672daeeff5e2","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"5e247e95-b985-48a0-90c7-34f90b8e8c41","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":-1},{"id":"f1b4c949-fc89-4d32-b366-67634e3d2b90","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"570a3bae-6908-4faa-b75f-97f8953d3a69","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"3e2f9b15-abd5-4e4f-9f74-e1badcaede11","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"fe8cf9b5-bbf9-4187-95e5-9170f524287b","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"9d0a2367-6e35-4542-b985-7bb19d430b31","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"0b194f78-a18d-4e28-a950-8d2b3600a8bd","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"87c1bc00-870f-4691-95c4-aad35d9d3d5c","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"c26c4e02-6b2d-40bb-b6ed-078807fff96c","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"09055d86-9c7a-4596-bc48-164a92494218","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"1145e674-0f2f-48ca-aedb-90182f3fc802","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"02ed2f53-3980-4124-be3b-099a973bd416","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"4b3be7e9-2306-4680-903f-81e75724bb27","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"dbf24990-8324-4314-985f-44dc86e1d35c","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":0},{"id":"fd3d802e-6197-4ce1-be58-04bd34d667d4","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"9d4bef62-81c0-4803-a8d8-f6bf942cd3ee","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"421403af-47bd-4a23-a8ec-774061d9cf1c","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"c7bf876c-d5ec-4d31-9807-0e1d774f02d5","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"4c1634e3-ae2a-47bc-9009-53cc8e1a94ee","groupRatingItemDefinitionId":"217b46ee-7162-4e03-8d20-9f44ef6d888b","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"c3bd69d5-18c5-418c-8409-43a6ca569988","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"17baf626-3191-4ec6-8d6b-c1f84a2123a7","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":0},{"id":"cd539213-843f-4112-b8cd-aa7bf53ac20f","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"cb7b5cdc-27e9-49e7-bdf2-fbb7b696a9b3","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"155b2650-9627-4470-b6c9-144dabdef6e4","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"b7952c96-62e1-44aa-add1-a5a44b10cd1c","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":1},{"id":"faa035ab-38be-4764-8d07-05f9f06c759d","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":0},{"id":"7cff670b-fea8-4b17-96cb-12746c6c2153","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"0c201a5f-8c6b-43b9-bbfe-35a11c68c7a7","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":-1},{"id":"f97331b2-849f-4827-b5e3-7f067725df43","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"90841afe-5ec8-4f6d-81ec-18d2b17529b5","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"880b59ac-30e4-4976-adc3-57865ad91a84","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"5d4d74ea-1dd5-406d-b5fb-aca8a5c4cc0e","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":1},{"id":"eadedd46-cb74-4435-98cd-53fbb572eab2","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"6c516c9d-dde0-4490-b4f2-da5d02497ea3","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":0},{"id":"ea735283-4d85-4b5a-babb-c25efeb3036c","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"eed5fcd1-026f-4ada-ab05-a20f5c55becc","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"99776d31-1628-4290-8b9d-d8db12f82d3a","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"148e479a-a3bf-4334-951f-cd2d6ee4ff0e","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"15312ae3-77b1-4d27-a635-eba00008f3d5","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":1},{"id":"51e0e69c-a9ba-467c-b5e5-4e688a3766be","groupRatingItemDefinitionId":"438f4112-2b9f-4f12-bbc6-95dae0f3e673","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1},{"id":"2cfd1eb3-e9c2-4ef6-9641-1005b97b4f51","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"a8c44461-5a3e-4514-b8ca-c8237a49bc28","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"fe5221e3-8771-40ee-87e8-e09cfca42b20","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"1ff68dbb-fcfa-4d88-b70a-92114d27a119","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"c7024d8b-83fc-43b3-81e4-06000d83b509","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"dd1820ff-cfc3-484a-b2e6-70a78233868a","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"fa384d85-1574-4722-a6da-157eb384ba9d","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"8701e85c-0285-4cee-b9d1-ebd0c1d8dec5","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"f7fccd1a-f354-4fd6-9967-1f74164586f4","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"7630bd66-52e8-4efe-b1ac-8ba5e470e83b","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":-1},{"id":"da4273d6-48a9-485f-b543-ee9570db45f6","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"cccd9241-2218-4f8a-8227-2e9fc6cd78f2","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"d90917fe-8aa8-4b6a-966e-5a8b3f29cfda","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"62397f69-a6db-4359-b3f8-4a01d1a73889","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"8f1aefdf-5ce2-4b7d-975f-8d7e2312b33c","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"120da214-cd93-4b82-983a-a67c6a7e8a06","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"829472ba-3617-48ec-95cb-98884a23a101","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":0},{"id":"ea1ebff3-9540-49dc-ad95-dddf11c9c95b","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"d0447c20-f7e7-4e26-b744-f5bdde140ef1","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"0bf3db92-96e5-4c5a-a55b-0eb051d7f2aa","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"ca7313d7-7899-4789-ac4e-9a81a2728c4a","groupRatingItemDefinitionId":"597e9a0b-91bd-45a2-944c-7e13a1265f41","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"56c5e442-94f8-4d21-975b-1b349070da73","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":-1},{"id":"51fc30fe-faa1-404a-963d-d0911c1e4cc2","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":-1},{"id":"ed16c668-9f4b-4cac-afce-7537a3287281","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"486b950b-7e9e-4ec0-824e-3cf0bf1c1ae7","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":0},{"id":"0c403e91-5c0f-4130-b8e0-58bb10328306","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"b7e42558-560d-4cdb-9d83-b08b5204b8f2","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":-1},{"id":"9b4b044c-0571-41d2-a07a-4f3cfc151c50","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"8765811f-a732-4e45-ac6c-53ab47883a56","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":1},{"id":"2f009517-9638-47b4-bba5-619b99f1b1b1","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"5e19ca5b-83ca-4a9c-85b0-0ccf9d7101b4","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"11124ad6-8c39-4f03-89dd-f752ac2bb705","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"d412a0b8-884f-4fbc-bd85-d01eb314c8d8","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":0},{"id":"b0288318-1da4-4791-a97c-16f3415fd8c8","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":-1},{"id":"68057fd1-fcc7-4491-ac3b-6d5e9f54a49c","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":-1},{"id":"309e980d-1914-4262-a101-2034f4c537eb","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":-1},{"id":"31bd2f19-96cb-45d2-97c9-7ce4d5ddb614","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":-1},{"id":"be0c5f5f-aa59-4513-ad47-8e99f6cfecbd","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"7fc156be-3629-4f3e-b9d6-2f0cf7102465","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":0},{"id":"2ffebfb8-eca4-4c59-bf00-b50b5f03085e","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":0},{"id":"a3b92336-96d2-42ee-b1c2-5369a00694d5","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":-1},{"id":"2f804ad4-01b7-4226-8403-037e2dad560f","groupRatingItemDefinitionId":"d3cc431b-eee5-4ff4-b1e1-8d019b903c6e","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":1},{"id":"aff2175c-bfe3-4881-8989-f9c03ea1d12a","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":1},{"id":"ef5c76e9-aa07-4753-9201-0893746ae87f","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"47e32877-f325-4c86-93e7-7eaa7d03044d","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":0},{"id":"8725ccc9-48d6-4a93-8abf-59aeae05c5a9","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":1},{"id":"37b5818f-9e6e-40fe-af96-ba5f1824fae9","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":0},{"id":"59113d37-f726-481f-8d30-95a57fe097a7","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"05d1922a-aeb8-4a6f-86ad-9cef2fae1467","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":1},{"id":"324592af-1f51-48ce-954f-062bc08f9be7","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":-1},{"id":"ad731aa0-0433-4bb9-81dc-a9e39db90ab6","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":0},{"id":"256dedd9-4f13-4934-9faf-92a8705b8a41","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":0},{"id":"efdb8d8b-7d69-4d5b-a18a-b26c8b77e7f5","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":1},{"id":"6d5d8c13-79bc-4627-81a8-32f696715d3f","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":1},{"id":"5b15b335-26c0-4dd2-aa0a-4f6331bd409e","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"a6638657-efa5-4dd6-b2e0-c3937debc89f","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"4a6259a2-5275-4c0b-b3e3-7c968f8e8c13","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"14096694-8060-4f7c-aa8e-f1710d3439f4","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"e2306a5d-08c9-4d1c-a6f1-a40e2a68fd93","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":-1},{"id":"507d6e77-3f10-46f3-992a-b4f789467691","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":-1},{"id":"c06155db-c928-417c-938d-cbe895dfb641","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"4361a87e-2995-4ddf-9afd-b6befffe518f","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"a621aff2-1fa6-40ef-afc8-04fa6ae8e999","groupRatingItemDefinitionId":"c19db850-ca45-40f6-8a27-4e4d6a77adc7","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":0},{"id":"4c2d9cf4-fcc4-46ee-9b5b-bb0e9efb789e","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"751b401d-7d84-436c-9c43-d17464cab85e","rating":0},{"id":"a6d328b9-5167-4016-837d-b3729cdbcf7d","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dc7e0344-a9be-4881-8f9f-23f0d09b5635","rating":1},{"id":"38ab14c7-3f1a-4245-9395-e5a094832795","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"9139909f-6b4b-4e46-b315-b41aa049f60a","rating":1},{"id":"35d906a5-087e-499f-90e0-8e68db097e9c","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"0d1c4f07-c4e2-4eb2-81b2-7854ad572942","rating":-1},{"id":"13142c89-4e89-428e-9037-f3c80f413a80","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a13c2aa3-5aa0-46af-85b3-f8604c5f074a","rating":1},{"id":"5630ee77-a08a-4da5-acc5-6d327d27ef3d","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a78654b6-07a3-4cfc-a54d-46889caf6a83","rating":0},{"id":"09d1ebaa-4539-4031-b46b-563bd6cc0c41","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3115a850-7f26-48ec-82d4-7b67a5201182","rating":-1},{"id":"7b815f18-c778-4791-b310-f0a15c49b5af","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c3292070-c7e0-418a-9e34-9970912bc168","rating":0},{"id":"9aadbb3f-868a-466c-bdc6-25c1d655da1d","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d0e80e61-6f43-45ac-9d44-f7aca64bfdf1","rating":1},{"id":"297bd1b7-3ecd-41a5-a9c1-b1bb1b389584","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5231f75b-9714-4eaa-ac60-5f890a5326e6","rating":1},{"id":"4f03967e-7c05-48e0-8a21-8c065940e210","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"727b939a-eb52-4b0c-b30d-b33470b05ca2","rating":-1},{"id":"255d27c9-2793-4bf9-b6a1-930a74595bc8","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1d7cb44e-8dea-4b92-a966-9c43e1626d47","rating":-1},{"id":"cfad12e6-bc67-442e-97d7-317d53d59158","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"c914e21e-2e19-425d-a61a-9f78233f3a4c","rating":0},{"id":"ed2b2c45-d2b2-4317-a6de-befa7e956524","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"3d758e4e-89cf-44d1-8e75-1c6d0c098687","rating":0},{"id":"19199cc5-b284-4e08-9f1a-bbb754e9121b","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"d6d245f3-8a8d-40d6-bd47-351bd00f9651","rating":1},{"id":"ff9ce9d9-c135-4511-91d2-9b40681b6152","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"5b26f4ae-87b1-4938-8979-86b93eb1232b","rating":1},{"id":"5789ef56-af4d-4be1-8943-584767cb4cd4","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"1291ff40-b3b3-4e96-ae46-1409c34ec0d4","rating":1},{"id":"1fbd60ec-624a-4caf-818e-44a2449147b0","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"bc166278-d513-4142-8319-231ec19ff932","rating":1},{"id":"97917a16-9521-43dc-8c4f-cb1f077b5929","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"dd6886bf-8745-4253-a420-d0db877c4b92","rating":1},{"id":"82197429-3131-4aef-b387-e973eb0d42bd","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"a6fb67c4-6581-4ca5-bc0d-fbe5ac737d58","rating":0},{"id":"37e8e14f-18f7-491e-982a-1903740bc51c","groupRatingItemDefinitionId":"7c9cfcd3-0458-4575-b4c0-6612223d4d51","groupMemberDefinitionId":"8d5b35d3-5d30-4fdf-b5e8-9d852ca72e2c","rating":-1}]}');

