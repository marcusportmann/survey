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
  IS 'The Universally Unique Identifier (UUID) used to, along with the version of the survey definition, uniquely identify the survey definition';

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
  FIRST_NAME          TEXT NOT NULL,
  LAST_NAME           TEXT NOT NULL,
  EMAIL               TEXT NOT NULL,
  REQUESTED           TIMESTAMP NOT NULL,

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

COMMENT ON COLUMN SURVEY.SURVEY_REQUESTS.REQUESTED
  IS 'The date and time the request to complete the survey was last requested';



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




INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, DATA) VALUES
  ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT Values Survey', '', '{"id":"706fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"name":"CTO ELT Values Survey","description":"CTO ELT Values Survey","sectionDefinitions":[],"groupDefinitions":[{"id":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","name":"CTO ELT","description":"CTO ELT","groupMemberDefinitions":[{"id":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","name":"CTO ELT"},{"id":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","name":"Peter"},{"id":"18f9a788-22d1-4927-ab44-6df544b23e89","name":"Adriaan"},{"id":"649b4887-bfb9-424b-9032-5c2720b2343a","name":"Alapan"},{"id":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","name":"Dan"},{"id":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","name":"Daryl"},{"id":"01623890-e77d-448d-a489-b3941b5c6bcb","name":"David"},{"id":"babc462c-63c8-46e6-9039-39aed3896751","name":"Francois"},{"id":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","name":"James"},{"id":"c4c49d21-a135-4e92-98c0-641aaa74a897","name":"Kersh"},{"id":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","name":"Kevin"},{"id":"95d297f7-b71d-4de0-8623-6e90082c2c31","name":"Linde-Marie"},{"id":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","name":"Manoj"},{"id":"305fc700-2458-492c-a9ff-19643a538b20","name":"Marcus"},{"id":"be83e488-d011-4bdf-9d64-099e0d965440","name":"Mercia"},{"id":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","name":"Nicole"},{"id":"87dd14e2-77cb-483f-b474-f75028d01b02","name":"Lawrence"},{"id":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","name":"Richard"},{"id":"60be5e19-f504-4e4d-8c6a-82a3733543f6","name":"Sandra"},{"id":"51d2f754-e9e6-4bf6-9305-74428911a539","name":"Tendai"},{"id":"ada58705-4609-4282-bfab-6c645e41739e","name":"Debbie"}]}],"groupRatingItemDefinitions":[{"id":"21e08bc9-6173-4e74-9082-44a82f966260","name":"Accountability","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","name":"Competence","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"b6fef420-77d8-4bb2-9729-549111d622fa","name":"Courage","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"ba306b79-8e78-4f0f-90c4-382b819b2876","name":"Fairness","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"39c12b39-337b-41b7-b8b3-c328f62f208b","name":"Integrity","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","name":"Openness","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","name":"Positive Attitude","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"18e0def5-e974-4e1b-a6a3-0feecd146512","name":"Teamwork","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","name":"Making a difference","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2},{"id":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","name":"Trust","groupDefinitionId":"328d99a0-5f3d-412b-a35b-bd729fdcb0a5","ratingType":2}]}');

INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME, DESCRIPTION) VALUES
  ('b222aa15-715f-4752-923d-8f33ee8a1736', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'CTO ELT Values Survey - September 2016', 'CTO ELT Values Survey - September 2016');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED) VALUES
  ('54a751f6-0f32-48bd-8c6c-665e3ac1906b', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Marcus', 'Portmann', 'marcus@mmp.guru', NOW());
INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED) VALUES
  ('ad6de33b-eca2-4520-be3d-b271241d2917', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Aiden', 'Portmann', 'aiden@mmp.guru', NOW());

INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
  ('18f3fcc1-06b2-4dc4-90ea-7a8904009488', 'b222aa15-715f-4752-923d-8f33ee8a1736', '54a751f6-0f32-48bd-8c6c-665e3ac1906b', NOW(), '{"id":"18f3fcc1-06b2-4dc4-90ea-7a8904009488","groupRatingItemResponses":[{"id":"31395c4a-2bd7-4a84-8659-2f579c0f13c4","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"01a389a1-44f3-44a2-ba81-0ab0624c37c6","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"cef32877-7170-479f-bafd-67e0c5d6119a","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"28515b4a-ecfa-4d68-a8c7-648c2c84d7ee","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"40746809-e7e7-41a2-8447-a001a27eeee2","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"36927047-4433-483b-a11a-aa4025703a3e","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"a7195406-28b1-4361-8c68-7696bb0492f5","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"702dfcd4-5c51-4630-ac51-50c938a32bf6","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"fa31a174-b919-474a-a695-af3dea233ae0","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"f94d57ea-3d58-485c-a10d-69d174ca6591","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"6d21b8ea-7b9d-4f99-abac-8641ce895fc8","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"9ba104cf-ea32-4f54-a9e8-48553675fe80","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"9277adf1-ce70-4e2c-b2c7-2bfecb55a6f3","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"7d51c7c3-7a0f-4fcb-9589-076eecaf983d","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"4ce35e1f-4ec8-405b-bd4e-4d7f5c1a2ef2","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"618d911e-6b9f-42e6-9c10-c323638d1acb","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"9fa86200-c0b9-4318-a47c-a8f50d5681ce","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"651d290e-6cff-4b65-a4c2-e05c0c92dceb","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"b58b720c-685e-460e-9715-f2cf30fb60fd","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"95c4554a-6556-4853-9685-6bd9a4900f39","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"4297ba9e-af0a-4e76-aeaa-964791ef104d","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"b38b27d7-e881-4ee4-9454-00313b18da91","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"111e8c12-79dc-4448-b4e5-456aa1448ea8","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"336e0018-1dc0-4c84-aa6a-92fa19581daa","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"3ea3b3c2-c438-4b8c-afc3-c4b76ccf6f3a","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"61c88f26-df7d-4b2b-ba08-69792e7c3797","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"33c5d853-4a19-4241-a6d2-c7d579119fcc","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"077bf111-06f7-4dc2-ba5f-d65afd159861","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"883bd533-edcc-4cdd-9da0-651a1bf22028","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"5d065412-6880-4897-abeb-a57ed27f92f1","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"5859406b-8b19-44b1-84c1-3f4bbb12c9e9","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"2fc06147-8568-41e5-b36b-eb569012c822","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"ed37c46f-25de-4e74-8119-2ab0322bd401","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"c55ab253-f5fb-4bc7-bdfa-5ee958d47d04","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"846833b5-f1d6-410c-9150-c8ef8cf9249e","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"1ba7a6c4-d566-4c55-bb22-694b40cf6e57","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"c57bb3d7-ef37-4473-88c6-4cd2f36f9ca8","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"f2514e3f-aad1-40d2-bee1-335fd36ee5e9","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"7f58e795-59a2-4734-8a34-ced2419f88f6","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"c33c42be-bd86-46b6-b2fd-52966fa68902","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"0eed00b2-b181-4bde-82cc-28fde5c01aad","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"71af6733-0ee5-4111-9c86-bc7733ff5888","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"b1237218-f8ad-4082-8780-07b17a2529c3","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"5774da49-d557-462d-a86f-4f2865352948","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"678656d1-0891-4d98-8c58-b09621a71c40","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"7469dfb0-9f91-47ee-8128-5bd517253a8f","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"a5e96b0e-b61d-4bcd-b4b7-c2dc7e3be0f5","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"bdcb3361-51fd-4909-aaac-d3b5d6474df7","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"6ced62d1-f909-4022-87c2-655b08a60c4d","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"00017861-5779-4175-acd1-7ac4abf6183b","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"c030d9d5-e9ca-4af7-8321-f8d00f8ed72c","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"ebdb05b2-2ec0-4920-9154-c391c5560350","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"f1ed4c2d-e502-4639-8c2a-149b9e1833a3","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"afb52ebd-bbba-45c9-9197-6c77a3f6368d","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"6de9e1fa-f93c-4d38-ab31-f99f88f7957d","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"5d44525a-2ef2-4f03-8b8f-f16b6726b1bd","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"a5fe3201-09e3-4c9c-9684-cb4871ad74dd","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"2ac521ac-584e-4484-8f38-60b69e62d383","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"c3f9acdd-8f9b-4eef-8213-dde443d460c6","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"28c8a6e0-98f5-4507-b06b-92031e4307b9","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"23deee2a-f01f-43d0-bd87-7a293a9d482a","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"c47e1101-082a-44ee-abbb-762a99349e21","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"ed8ca44d-a9b1-4685-aeda-234b984dbdd0","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"a95ffe3f-9d13-40e5-b816-4399c5ab7c88","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"8b92c795-aa04-4c5c-93b7-07f36ab7f95a","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"db5b0d33-5c95-44aa-8a09-945d6b0556ed","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"2cdd3d0a-62af-46cd-af8b-35cf07a0088b","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"b175304b-4863-43c0-8f30-7a8f2c508921","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"69e1c428-f102-47c3-a70e-dd5c4861854f","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"cc008024-aa66-47f2-ac40-74ff0abbd01d","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"1b962474-1e43-48ac-bcc6-eb649e14ef44","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"95cf0de0-65ff-41db-a575-edbd1c6fae91","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"28abbc46-5b78-4df2-97fe-fde30348b076","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"4a5f506d-7b00-4ade-826e-8d968fc7d135","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"72b09f80-6f78-405e-8bbb-d3b8c5e72e25","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"78ba3834-3f41-4dcc-b7c2-7b98313aaf3a","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"27e0f535-e1f7-4f5d-b960-d714c7e46269","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"62750400-0e0c-4005-b263-3b5172c6d12f","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"ab75a34d-82f0-4e47-ba43-a3469d037e78","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"6c1b3c4c-d576-4935-8062-49c7af9d23b0","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"b6fb652e-fec3-442d-9bbc-2651536fed76","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"2353314a-619b-481c-9b2a-c8d29a8dc5f2","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"83eac08f-ddf7-4c02-ac8e-d0c8345a1a0a","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"340f2525-74b6-4345-bf3b-9e5b82300c1e","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"543f2ed9-7174-46a5-abf4-64713cd0bbd7","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"8586284d-3898-461b-b5f5-5c350c024528","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"ad538e0f-a09f-45bc-bffc-a8680048b3f9","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"27ca159a-3ce4-4a5e-b50f-6e03ca5def38","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"baf3ddd8-c27f-4ea7-94cc-3cae58cb75c2","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"3d9cbc91-ebd7-4d0f-8747-03e0e425a953","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"bacce359-6da6-4d88-884a-41b9b4de5512","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"7da0f978-6982-4175-8fa0-20e0c72182c4","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"5b063ead-1ad4-4beb-ad77-a89082e058e4","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"af57289b-9ccd-457b-83af-e50121223dec","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"d872acdd-689e-4cf9-9de6-27710ba15682","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"16e97513-9940-43e9-a777-56d7fac54858","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"f69fe459-ff9e-495d-8636-bee8333f4e8c","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"f5273756-b0af-4889-a3cf-ad336931d4f0","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"5297c74a-a37c-4f68-9064-fc0998a9e4a6","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"51519ff8-2f35-4383-8d5f-738611e36a6c","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"57867b94-e9b7-437a-9e19-c4713fd4d199","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"c35d478d-54c7-41e5-8fbe-2e1bbc842ec3","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"b0cfd1e1-51f0-4bd5-840d-9fc1c5117c71","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"7e5a7185-661b-421f-bfdc-7b66640c833c","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"eea2bc03-4d05-449f-86f1-901462c027c5","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"742f1620-7de1-4d02-a0e9-80bb421b35a8","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"2d828e2f-0399-439e-b3e5-80bfeeedced0","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"0fa24a44-59a1-4c84-af27-bafb3bca2ad0","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"b6e071ff-c58b-45a3-915e-0b7ec675b980","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"271d9dd5-55fc-4b8c-a2d2-a01d042a1698","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"c596fa39-9861-4f01-b303-6162aba2d7f1","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"535f86fb-50df-4495-ba7b-8a01c377d89e","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"b93e1c6c-acba-4b2d-b824-1fedc49ef31f","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"3296e4d7-b953-4241-bd07-49f6e99efa82","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"3a95058d-23f0-4efa-8ddd-5873f96e7b4b","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"c2e37289-552a-4541-9a40-94c261543f34","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"74bcc979-61fd-4487-8961-c1ba03b92d83","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"8bbb8d55-c6c7-415d-9ec9-ebd01564d3f7","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"aeb39c1f-d0da-4b15-8362-d817eb6152b2","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"aefdd36b-4dc4-4f0c-9a79-c2c913209b09","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"8c6695b0-43df-4d75-9e31-f50e553363c5","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"02ef0c85-4b00-4192-bc2e-3a8c5852e79c","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"2f5350fa-0ea7-40ba-8628-2efd8534f0fe","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"6d11d193-617f-4b36-b0c3-e6e931ef6ac7","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"a3e7eb37-2489-40c1-814d-2164f5715f2e","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"34693905-d175-4a95-a52a-4c5ace6d1dc7","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"ab3d7b1f-d458-4dda-8f25-60afe292b6c2","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"7f035f91-65c1-4f50-b8a4-a4b8ec708af0","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"4cfb9a88-4ffc-456a-93c8-bb483ac1a04b","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"552d5775-e532-42e0-9eaa-340e7801615f","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"4dbb4bd8-bf9b-40e1-b97e-5b4a2234f288","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"063c9d4f-7914-4e6b-969e-2755126275a7","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"32b39eea-6245-4819-bda5-ca36bb0ff765","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"cb8b48ec-f2a5-4865-96c1-0c0cf167dff4","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"c55f00f1-b5c7-41d2-94ed-80537d767c1d","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"760ed6dc-ec9a-4f12-bd7d-89163ea58a0e","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"74ae05af-a6a3-4c50-81db-ed643216d293","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"94be2482-ced9-4519-a54d-553483c1c5d0","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"909cd9ea-3b15-418f-b2ba-b113d0fca931","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"280f4047-8d98-4fc8-a503-41325bfeb7d5","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"c3c05432-a7e6-48d5-bb1b-57978dec965f","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"072777ff-42f6-4b85-83c3-05b8b72e0ea0","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"1bcb6a32-389d-4105-8895-2ba08b74a4f2","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"457b7a41-af77-425d-b243-fb3fc561ada0","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"949a9fa7-dc8d-49b8-8fe5-b7bb1b3649f8","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"dd103cb1-26d6-4b17-8cc6-50fc1c5ad43d","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"1db25f72-66b5-46cb-a82e-708953004a4a","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"7e198448-6322-4382-92f1-74fdd9ddcfe0","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"04814998-5f65-4b9c-a493-54b362df202d","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"c5f01984-d49b-4ed2-86f3-9246785e498f","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"63b2568a-91a0-4659-a9b7-ecf7a4d375a0","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"6a7634dc-8996-41fe-bf40-fcc4b23a83f7","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"990416c1-d32e-4733-a957-bb2371bc2f80","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"2071918f-6887-4917-a514-67da3ddb4feb","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"3ba9f141-f108-4046-b0fb-7301cec20169","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"faa21c5e-69c7-42d7-8d6b-c8e53a7ce539","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"4f392821-dcd5-4d3f-91ec-cdc0eea8e71f","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"a9fd3a9f-a836-40b1-b038-7c2d67ea6bdf","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"6febfea8-1477-4a55-901e-f3aa73d1fe61","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"825d7447-6176-42a2-8c9f-96fc48dd6363","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"f7f2596b-076a-4b5a-9ef0-808a28c0565d","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"fb3e3640-0c07-44ff-ae9d-d35b4ac9ca73","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"c21d70dd-fda2-4b8b-b629-d9ab61720502","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"a4d2a5d9-e441-4271-8557-ddbddee5fd5e","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"b1403c04-3f42-4c9c-806a-767a12021476","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"d1e81333-fff2-4298-b16e-c2ae3f68a1b3","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"a08b0d42-73ab-4448-949d-df7b1875ef3c","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"75a901e8-c858-4161-94c6-ffa6112bc31e","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"1ab687f8-6bc0-4261-8ce4-cf5d32ec84c0","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"4e05f8b9-aa81-4365-ae9c-bddfdff0cff7","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"58650b1d-8102-4939-a327-5a7e2e0a8afc","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"b19862cf-8e5f-4c4d-b607-2d3b527cffbb","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"19ccaeb8-c9f3-4625-b3d4-d56adddb834d","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"8c07fc50-6029-47d0-92ee-20c9644df7e6","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"d2cf1cf2-573b-4c2a-bd0b-4ec1a5940111","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"34d413d8-5a0b-4016-b6dc-cf885b6ef1a9","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"2c673ba3-37e1-4a01-836d-2eef46adc321","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"37790dd6-2acb-45ec-887e-ae345c8927c3","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"a0c57619-e035-42df-b27c-793c25e7c9ff","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"c0061f98-66a3-4f14-adc7-0bc7a186c995","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"23454287-f517-4224-a5fd-edfbe085edea","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"0b0577ab-b330-4bc9-997c-2a0f9db68020","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"a3b3e8ad-793d-485f-9f3e-590e03e25615","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"3b49a78c-a04a-4707-b0b5-22c553ef340c","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"d3a9b909-3b10-460a-b4b8-97b1b6a6f9e8","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"ac6925a7-862a-4d9e-ab20-475face119ae","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"dd749f7c-ad84-43cc-bf35-d7a866ae9668","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"ac398596-bfa4-41c4-8992-066a1d0e36b4","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"cf1f8a19-b134-47c1-a5d0-3e76d441171c","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"7a46d15c-55bb-4ffd-9310-b5fe107bdf54","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"f084d571-86a6-4100-9aca-d32fa7ca20f7","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"d2e76a76-7f62-477d-8032-00f9199611c8","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"8f4664df-a250-4d5a-bcea-3e7cb2656a79","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"eaa36ec8-09d2-4b79-b8e3-6c38fe9bad63","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"f4d6e244-de52-44b4-9161-ff5b0d72be83","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"6f0dcbc6-61c1-4ca0-a966-ebf6f41da380","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"dd1e5e6c-dc6a-494c-be1b-0b3c77860307","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"1680aa48-20e3-4d2c-882b-ec2940577ffd","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"47b2efd0-c0fc-411e-b226-70de7c72c0fc","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"31378799-9aaf-409a-98e5-2df18985faf9","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"a488673b-50c6-4ede-8fc8-6c9827338488","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"895a7e84-bdb7-4293-b898-31df90008ad2","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"9d8af3ad-67ce-481f-a05e-d029694506df","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"325f51b7-9efe-402b-9fd7-c98b6ac88d30","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"9a7b757a-b570-49f4-9a4c-1d08bf5e178f","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"6737f1fa-c0d8-4615-8386-1a66d136c50d","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"63a46407-cbb9-4460-843b-a53843bf1453","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"470e4bf5-bc22-4abe-bd44-71e1997932e9","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"e78a7904-649f-49be-a516-f57c2257b6cc","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"f728c44e-d15f-4da8-8198-86ad12b81542","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1}],"responded":1477841592723}');

INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
  ('9271229e-0824-4098-8477-1a564c0acca1', 'b222aa15-715f-4752-923d-8f33ee8a1736', NULL, NOW(), '{"id":"9271229e-0824-4098-8477-1a564c0acca1","groupRatingItemResponses":[{"id":"a400c617-4895-4fde-9512-635ea43955df","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"bc2a7a86-fd58-4922-b47a-6331a1b2523d","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"803f2514-bfbe-429b-9ba4-f37a6a370e2f","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"bacd3933-00fd-42d7-ba64-e917d8261f1d","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"9fe1de96-c7a9-4863-a2c1-89bf7515acbc","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"6247da07-bc64-4c18-beb2-ea2486704d8e","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"35c6b2ca-2ecf-4e76-921a-912be916a451","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"86e96c18-2dd5-4142-b51c-b90f15dfc37f","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"ad950f0e-0887-4963-bd30-2f3b69ce7e88","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"df4bb316-b992-4dd5-a2d0-f10f90ef2061","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"49ddca14-134a-43ae-b17e-fb1a4e6a955b","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"a7a628a3-989a-459d-9834-42af9d0ccd00","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"bebd8f29-eef6-4c47-8f70-6def212f9572","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"d79693cf-4daf-483f-997e-9fad26ab6988","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"485e131a-e487-4591-ac3b-eb7a5a0d1754","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"697aec7b-da19-42e4-b8c1-475d24d1c007","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"36f28575-cab0-4abe-8384-94eacd099866","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"72b82470-1cc3-49c1-8f83-d74e839b088f","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"677a7778-4194-4056-a284-4c61ae82428b","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"b569e53c-99f3-43a3-be34-894a08001c06","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"d84e4cc2-9bd0-4ea0-aa02-dd7e1476bcc7","groupRatingItemDefinitionId":"21e08bc9-6173-4e74-9082-44a82f966260","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"6e78d210-1835-4120-94b4-29a6231f300a","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"4908e5a8-c3b5-4873-9a45-71836db85282","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"32c11698-5bc2-4e93-b050-63091cce3716","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"d8eeaa5f-eaea-4411-a22d-6c5d285fa36d","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"6d451926-98a1-4f90-859d-acac9ae872a4","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"d136670b-f466-4a2c-b0f5-344a98205dc9","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"7cefb6c5-2096-4bc8-95d4-5ca680fb3555","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"aa846155-4f7a-4684-9e1e-fc850cdd6079","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"841b7d7d-e652-476e-ab6b-9920a7581fad","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"140ca89a-808d-4d34-890b-38c7f17f5e29","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"ac116fb6-ad68-4e06-8d4d-8f42a0aff335","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"27a2e13f-9a86-46a2-bc73-a7ab2ebf250c","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"3183046d-410f-4bdd-aedc-544c75bb62e8","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"4492584b-e1cc-4f13-b6e6-7948b1353e69","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"c1103850-c3c8-40c4-b725-c3d44e8516a5","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"6a720619-5f93-46df-88a0-789a0cd1b45a","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"0c87a7f8-23cd-49ba-a17b-3b460f206259","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"bd90a23c-82d0-44c8-8108-b4ffd9079b3c","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"54e5c598-86aa-479b-9cc8-a5c2fcc2c361","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"5169c2af-3bcc-475b-b930-a1d5c43186a3","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"2bdf1cec-1241-4566-9eaf-93c99e5cb921","groupRatingItemDefinitionId":"4754cb5e-7244-4a8c-a9b5-909335ef4f29","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"44ee76cf-f023-4adf-8844-8a71a20042ea","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"5e961ec5-d582-41b0-9e7e-ae7232866950","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"4671c3ea-195e-4810-a679-6a9cffadc3b5","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"9a386bf2-ddba-4b7a-b82c-4dcee02ba8ec","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"5543c377-f927-4cca-adb7-683cf0d64312","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"7bdb472d-352a-48b6-b13a-e32f4a717c7a","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"48c233a6-c9e6-4815-b8d5-bc5feb5ad17a","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"fd41b04d-dd39-42d7-b669-b0cd6f65a47c","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"ece07841-37f2-4eb8-ad1c-64b45922e1a1","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"382a2ef4-38e5-4691-b235-745430229b75","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"e951d9f6-358c-46b5-8a66-8b8f7a9df881","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"ae11da24-40ff-42d5-950e-bfc4e5e99342","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"45732590-2482-4dfb-94bd-2a497916aa96","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"b2c95970-7aaa-4047-aad5-3b1136e64cda","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"39a40f60-90e6-44df-89ba-d1ee3c458a60","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"d674a291-2e68-4e45-a47a-fd26b0d7c4ce","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"26a8d975-e579-498a-ad39-8f17a91b939d","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"929fc8c9-7303-49fe-8f8b-b592a7475b66","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"2255642d-8b4d-4ece-a13b-609d2f7c6f2f","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"32c895db-5b79-4a83-8926-6a958465788a","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"24ff3bbc-1c92-49de-9b41-3b99ab7a72ee","groupRatingItemDefinitionId":"b6fef420-77d8-4bb2-9729-549111d622fa","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"0d807851-ee98-41a5-9a60-3fcb26257f1d","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"d9f0cdef-e5ce-4d67-8a94-60516fd2a4da","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"1d75ab75-0acf-47f0-ab7d-e79aa8699bdf","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"b032ad10-72b8-4d3b-a9bd-4a213a44d370","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"b77e76ce-e9be-4983-a76c-cf8078967875","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"3ff175a4-678a-469a-abd5-dae694cfb71c","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"41d229d2-6dc9-400f-ab7c-00eedb7e444f","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"56c5a9e9-1a75-44ea-9875-39e33a2d9723","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"24d5c337-8340-45b6-ba12-c80ca5cc114d","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"2df4d786-e5ae-4cd0-8b0c-6729be2d4cdf","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"59f8aba2-ddb1-4c40-8552-3284d08e53b6","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"eef83bfd-3dd4-424b-80eb-ea677f9abeec","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"5346b6ef-b25b-4fb9-bcda-24e9a17321bb","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"c6c1df67-301d-4d62-840e-06ba5d9a6c37","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"c1d97fbf-d6e8-49fe-918c-9d0caa68e8fb","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"d0cf01c7-c296-486a-a170-bea34999f77b","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"63070cff-8253-489c-b1ea-ec9a15483577","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"d556f623-5ac5-4b10-922c-0c46ca19aef5","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"acd8e800-b1f7-4c35-9847-7847d46b997b","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"d33e1b94-63ca-4197-8e4c-86f73fa45004","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"e6c1153c-22aa-40b5-8de0-2295c92b015d","groupRatingItemDefinitionId":"ba306b79-8e78-4f0f-90c4-382b819b2876","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"96ecc59f-e38e-4e33-8e4c-b758cdfb5b14","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"12c345b9-213d-4f83-8276-cec18b6abbc6","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"463dab32-dc2b-4115-aa66-3ad75618f471","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"2aa816b2-46bf-448c-b015-ef3b6dfc87ae","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"ea57a5e7-c722-42b1-b279-31a90c231a94","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"05df4d6d-7556-40e5-92eb-008e0b6ebab7","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"2e95e311-0c7c-4cad-b7d3-c3a299e81430","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"e3288d75-7b33-4f4c-a5c9-5c6796c5431c","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"f66a3186-712a-4769-8d5d-9301eda8759e","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"9b817a88-a3ad-4ab8-9151-99218a78dff2","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"15a4fae3-93ff-4669-bc4c-1a055d2d1712","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"78131aa4-e8e7-43ee-bd1f-e8759738101d","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"a71ed70c-c632-4941-972e-44fa745f8973","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"68c43fbf-d333-4d52-a909-484ae571db79","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"92992b2e-a6b2-4e42-8106-fa6dc983bed1","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"87aabad5-81f8-41c9-a130-168725337104","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"68abb1e1-3aa3-4d6a-a5e6-5b534be7c4d8","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"fb4d4f98-45ca-444b-ad92-c03ee5c5b4d5","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"cc2dfa3a-f351-440c-9e6b-2c7950cf1ade","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"ebeb2af1-eef8-4d39-bbf7-486da44da303","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"36fc3d59-345c-46d1-942e-c9895394f58d","groupRatingItemDefinitionId":"39c12b39-337b-41b7-b8b3-c328f62f208b","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"8cd61be8-e432-4d6d-9d3f-4d6cc0d97b6f","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"a241eb41-b12f-4d70-b493-1db1e5cc4dab","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"e04bed4d-2856-48f5-8571-72faaf00dff0","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"954a8741-25a3-4c20-aef9-a5b29dd15415","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"ce35e531-3460-43d2-a6d6-07d728860ae4","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"79750f6e-23a2-43cc-9a99-ae3c60ddc259","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"db4fdcb4-7508-4d0b-8da3-a5a26c7d23d7","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"5d4a83af-a94a-41d0-8720-cf62b746dca1","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"69572ae3-4ec6-4a6b-ad0e-020929bde317","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"0ce2a07b-a742-454f-9dbd-7a99cfed940c","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"45937a8e-9f9b-4dcc-a3ef-f9980b9c0a46","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"1468c5f1-d254-4ef5-a164-29936cc932d9","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"143dd82d-7389-4c9e-b38a-ab2605c8336d","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"ab27cf02-e12f-4615-a8d6-478bd44614a3","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"52c8ca47-010c-42bc-85a8-166df7038507","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"dc47dbb7-d8b9-474b-868d-9425f8c363bb","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"00879e61-3a51-4167-baa0-430f9e2ebba8","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"1f52a143-3d54-4ec1-af84-44b6ff87d0c0","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"7e796243-116d-48e6-87fb-6164cf052e2a","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"128751f4-02df-4a1d-8e96-32bf05207995","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"421126c1-4788-4a33-98e9-d02de5ca2956","groupRatingItemDefinitionId":"382d1ded-2ac5-4580-aa90-dcf9829ed00b","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"afd30417-6b9f-4734-92cb-7aa0d79e01a2","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"a77dedab-f438-4074-b2d4-c23eea5aac3c","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"5427b08a-e7ae-4028-8a66-4b06b82f73b7","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"0c1261ca-6c47-498b-9384-28766cc984a4","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"5f500719-1776-44ac-b1a7-e853b83e8ffa","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"ba7d946f-8b54-4c70-a87f-1e54ddab0509","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"3569b093-8ff8-47f4-aabc-3d5850ff74f5","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"719d2613-8892-4679-b1ff-31775e6bee4c","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"990a14fc-d59e-41b4-acfc-bf6b1fe4bb08","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"bb1bcfd1-090c-407a-8cbd-87afea1d82a4","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"7e34e5f0-41c5-4592-8a0c-ba1b8a4e2174","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"b3189e0f-3869-408f-bedf-fc8e4d6dd318","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"0ca447a2-c1b0-4b0b-8abe-1a913733dba7","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"243ab55e-5332-45b9-9e94-d9db16298ebb","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"ea435e40-1316-4f40-beeb-aea3a2335f9c","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"00f29002-3f26-45ca-b3e3-5636a9bd5ee6","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"d3213ffe-2ced-4b67-9a48-d2458348082a","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"e9b46b70-29af-47a1-84ec-a5d3fa6a35d7","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"34b4f2d5-40cd-4512-b4f9-500e13d3ed6f","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"37b0ca95-41a1-4068-82a4-a5675f5b4cbd","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"f12d9e08-aa00-493d-9626-3f6d1a682648","groupRatingItemDefinitionId":"fc182bde-1f7e-4a24-8394-f23c9b6eb7ee","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"2700ce57-d805-4514-abd1-8d0d4115dacf","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"006d89f0-4bbf-4a85-a802-671a4583b628","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"96b83a8d-0f82-46f6-b4e0-65b8e7237392","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"6c003c4a-7117-4fb3-a615-f29ec608a3c0","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"4cbee364-2e32-4df1-a036-76392fc99f12","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"a8ec7c3f-2e82-4410-bbe0-1e38ff2d7b58","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"f970a325-d0dd-46f3-a331-729fd749a3bb","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"15c137b6-7784-45a4-a51c-46d6e71cdfdf","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"f98391fe-b752-4bd0-9394-c31a93a2d66e","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"33541991-a61c-46ea-a8b9-855953d44ac1","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"3391c2b3-aba6-4338-8d61-942edda89907","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"a5435718-486d-48e1-9676-a2ff64e15232","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"ea52b9ec-e735-4bb7-9bcb-4af31cca728e","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"35ee22be-bca9-4b8f-9fc1-6a35831e1e30","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"e1536be0-3904-473b-9485-175a909b4ebb","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"6360e323-000c-4d81-8ec1-4dc725532db2","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"7af45e7a-fee3-4a86-ae78-b07112285816","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"158d7648-66fe-4ebb-8ca5-139f137c6be8","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"05aa3ea4-31d7-4de0-a039-e84cd64eee72","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"e57b09f0-86a2-48a4-86dd-e45c4b5b54ea","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"bd30168d-2535-485e-9abe-a384cda23024","groupRatingItemDefinitionId":"18e0def5-e974-4e1b-a6a3-0feecd146512","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"0ed788af-61a4-4d7d-96da-cd25b8d06c11","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"59ebcc8c-2082-4126-89f5-307c5aabe099","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"ff5c1a3a-8ee0-4b63-8f38-886410b9f070","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"07f18e43-68a4-4ad1-b3ac-0ee50c8acce7","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"f62970c3-5f1b-43d4-b89f-34c9898c3061","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"837a2702-f148-46cb-bf80-f4eb93e62fc4","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"75ab8772-4800-44b3-868c-62f04c8c1048","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"09bf3298-7520-4eb4-b44e-06eea3a5a8e6","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"0910d78c-9fc6-45bf-a2f8-4de1c30327df","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"11a59a83-ea27-4b8c-9b24-8a2ab4376ecc","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"18ca2658-9401-48f9-b82d-0a433f004344","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"c301479d-75d5-4ee3-b739-c869cfc47b47","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"10b6cf96-dbc2-4d5d-bb53-449d8b9e62bd","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"5b9663bd-da6c-4991-8a27-a22dbe5621cb","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"78b90006-a7d2-43c6-9d91-cd75c9feb2a2","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"7eb59e77-c20f-4883-9b47-a8a4f42e9e5f","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"ff81dff9-50ce-40d3-a90b-251f9a92e1d3","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"b5ee6c32-6544-4856-98ad-1c85b685d9b2","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"386e670c-74a8-4f13-a78e-25a32133a264","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"6fbabad2-0d15-427f-8c5c-ff5810ab05df","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"14926f82-87a0-4f02-af2e-b7478c7767e8","groupRatingItemDefinitionId":"f7eef4ef-f3ea-4d5f-8242-02a2b43b3900","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"fd7cbe90-5ba4-4730-a2e6-de7d5b8cb991","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"61bb2b11-c91c-4088-8f1f-dae94aca9d13","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"c1aedac1-fcd1-4113-925e-4607964c235e","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"0ea4fe64-2334-40b9-8e53-d1be3e5ee6ee","groupMemberDefinitionName":"Peter","rating":-1},{"id":"3137635a-22d4-4fbf-afcb-a8cd1623adb6","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"18f9a788-22d1-4927-ab44-6df544b23e89","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"0a0d7dc8-248b-41a7-8b82-39a99c35f87e","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"649b4887-bfb9-424b-9032-5c2720b2343a","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"fcd4b85e-2068-4c9a-adc8-595fbf32d9f1","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"44f74f15-7c4e-4f9c-a269-c6e843bf840a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"92c5fe80-811d-444c-b91d-f43830d696e0","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"42ca01ed-51b4-402d-ac76-8c0a9c2fccef","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"b057c55e-db8c-47bc-93c5-ad180af1ee03","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"01623890-e77d-448d-a489-b3941b5c6bcb","groupMemberDefinitionName":"David","rating":-1},{"id":"27bb66f4-c249-4b44-a2d4-97de817d0ada","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babc462c-63c8-46e6-9039-39aed3896751","groupMemberDefinitionName":"Francois","rating":-1},{"id":"966fc0f1-5353-454f-8272-20a9c1e6d6ae","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"a0ddb185-5fbd-4057-9dc7-6524b99ea88b","groupMemberDefinitionName":"James","rating":-1},{"id":"98a4d333-d8a8-4c13-af82-58e89bcd6285","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4c49d21-a135-4e92-98c0-641aaa74a897","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"f88fbcac-6520-4cef-b4cb-7b2601b64a85","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ece2e04c-5ad6-4bbb-b630-0b56cb993960","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"40056cfd-8554-4c19-a447-bb188ce9d208","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"95d297f7-b71d-4de0-8623-6e90082c2c31","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"7c8a770b-380e-4db6-a59f-010789b7f219","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cdf2350-573f-4b6b-8512-b0b0dc3be2c0","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"10023bf6-7bc3-4c76-91b3-2b47374288f9","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"305fc700-2458-492c-a9ff-19643a538b20","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"c33ee511-396c-45f2-b7eb-2a2751dc96e4","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"be83e488-d011-4bdf-9d64-099e0d965440","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"dcb32679-26b4-42c8-a64c-b297c805dd5e","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c1b39b0b-4966-4f8f-91d8-a468ddd18850","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"325013c5-a9fc-4910-8683-fbdb2271406c","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"87dd14e2-77cb-483f-b474-f75028d01b02","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"d1c134c7-8e05-4624-8e1a-2e31f8975710","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"02d119ec-e5a4-4796-9cfd-3c5a6f5fecce","groupMemberDefinitionName":"Richard","rating":-1},{"id":"121077ed-6478-4697-b181-6561f4af486e","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"60be5e19-f504-4e4d-8c6a-82a3733543f6","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"5356b8dd-3e2d-4d57-9631-4cc73a6c5e27","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"51d2f754-e9e6-4bf6-9305-74428911a539","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"bd8820b5-2407-4f5b-a775-f0ac476016fa","groupRatingItemDefinitionId":"22a4fccc-0de9-41b5-abfa-0bffb7c65fd8","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ada58705-4609-4282-bfab-6c645e41739e","groupMemberDefinitionName":"Debbie","rating":-1}],"responded":1477841592727}');
  





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




