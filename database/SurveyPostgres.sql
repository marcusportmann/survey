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

COMMENT ON COLUMN SURVEY.SURVEY_RESPONSES.RECEIVED
  IS 'The date and time the survey response was received';

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
  ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT Values Survey', '', '{"id":"706fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"name":"CTO ELT Values Survey","description":"CTO ELT Values Survey","sectionDefinitions":[],"groupDefinitions":[{"id":"04cca3b0-29de-4b49-b0ac-01e5d3686794","name":"CTO ELT","description":"CTO ELT","groupMemberDefinitions":[{"id":"adbfd97a-681e-4da4-a369-a6c25a428e1e","name":"CTO ELT"},{"id":"33a65ef3-fe40-4499-9385-07cd125ebbee","name":"Peter"},{"id":"aeee5b77-d69e-423c-960b-e27d8425ff61","name":"Adriaan"},{"id":"8ae82c0b-bee2-43cc-bc4e-130f8d70f233","name":"Alapan"},{"id":"c6ad346f-e11d-42f6-9501-04b7027e1bc4","name":"Dan"},{"id":"4c6d65bc-9115-4694-8a6e-b890dbe10467","name":"Daryl"},{"id":"2f78d49e-dfcd-417a-b0c8-8dbaa44105cf","name":"David"},{"id":"74b7ac7e-9a4b-4c4a-bb36-84d0442762b4","name":"Francois"},{"id":"c78cc15d-da58-4a93-96ac-e0d8caa70309","name":"James"},{"id":"2dff9a3c-69b6-4a40-af49-d10d1759f8dc","name":"Kersh"},{"id":"e8b6df11-f048-4576-92e5-44547679e689","name":"Kevin"},{"id":"02af6c62-24ac-49b9-ac0b-6d5bcebb4e5d","name":"Linde-Marie"},{"id":"810c6b28-de81-4ee1-ad98-e66f5999e572","name":"Manoj"},{"id":"f34ad30a-66e8-45f0-aa9c-f7c1050a64b5","name":"Marcus"},{"id":"ecaa5a3e-1094-462b-acf1-cde372682500","name":"Mercia"},{"id":"3eb67306-c495-4c8c-8747-6de580ef225b","name":"Nicole"},{"id":"04438989-c596-476f-a673-4442cde05ccf","name":"Lawrence"},{"id":"0cf0d190-53cb-4ccd-8586-9b572e700e06","name":"Richard"},{"id":"f8a218c6-aaa3-4632-bd2f-b62826ac4831","name":"Sandra"},{"id":"e73bce84-a97d-48f7-aa6b-16b3d18bcbe6","name":"Tendai"},{"id":"116cc6cd-d7bd-4e57-9a45-90a513c81de7","name":"Debbie"}]}],"groupRatingItemDefinitions":[{"id":"391ac6ed-a5d6-4962-90c6-4defd2aebeae","name":"Accountability","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"806e5b10-01d8-406e-ac0b-5e869698dfaf","name":"Competence","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"21bfd6b6-f360-4891-8170-5200807b32dc","name":"Courage","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"61be8d29-1667-4acf-8dd7-52b9c6f754e6","name":"Fairness","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"999c043e-3fac-4648-8848-6e50ebee364a","name":"Integrity","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"bbdbdb9d-3342-485d-8aae-ee50738aa70c","name":"Openness","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"dc67c9f4-3eaa-40a6-928e-86b4e09dd2ee","name":"Positive Attitude","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"4d02295e-f062-4569-bee4-307be32300c0","name":"Teamwork","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"9c215a7e-9450-401c-9a09-b25bdadfaea7","name":"Making a difference","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2},{"id":"ab6fabee-6eea-49c5-86bc-2cd0b0c1288c","name":"Trust","groupDefinitionId":"04cca3b0-29de-4b49-b0ac-01e5d3686794","ratingType":2}]}');

INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME) VALUES
  ('b222aa15-715f-4752-923d-8f33ee8a1736', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'CTO ELT Values Survey - September 2016');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, SENT) VALUES
  ('54a751f6-0f32-48bd-8c6c-665e3ac1906b', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Marcus', 'Portmann', 'marcus@mmp.guru', NOW());
  
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RECEIVED, DATA) VALUES
  ('101a79be-e72c-40be-b86b-2a6feb887cef', 'b222aa15-715f-4752-923d-8f33ee8a1736', '54a751f6-0f32-48bd-8c6c-665e3ac1906b', NOW(), '{"id":"101a79be-e72c-40be-b86b-2a6feb887cef","groupRatingItemResponses":[{"id":"62a53327-add9-49db-8990-763bca80c576","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"35a024d0-be59-4d1b-8529-61813fb28159","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"219b0cc7-191a-4582-a83e-950217f95f5a","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"ea2fb42c-7695-4ca1-9872-1fe1372ca98d","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"798da5dd-7cd8-456d-aa3f-cb8f62b41f99","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"6acc6061-8278-472e-adf8-b90db87ce9e2","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"34e40cf5-1802-42e7-85e8-80f3aa466b13","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"975eef5e-a251-4f7b-9a78-f486fc1de2b2","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"29d81b92-8e7a-4fe0-93a9-09bfe288f741","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"29d5c857-f56e-47b2-8810-b18d46e92a16","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"6de6bab0-0cc4-4051-a2a9-a2fc9afe03cb","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"1decd1f7-380b-4a2d-a6f7-bfb872b2a25e","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"41241d5b-a235-44f3-a577-ccd206c5ac12","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"6bdfd78b-152a-45f9-9b60-4deaa66cc81e","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"e4e745ad-cb90-4712-bc4e-764bbf5b69b0","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"2e8c0188-a620-4ebd-b0c8-d3d54e9c1d21","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"7d237ddd-91ec-45df-a5a8-23ab4831e1f5","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"536f6f5c-1787-425f-894c-8faaebe68ad0","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"ed6e1428-3471-4ff1-b9e4-9bfcc8904a9a","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"90cbe5c8-6858-441f-ad3c-f8bc52848d25","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"bb0b6d94-2297-4969-9c9d-f7b24c8478d1","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"d561643e-393b-46d7-b0be-b4d08b8d63e3","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"03e4a2be-76e9-438a-aefc-4e27623698b5","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"e0e459da-4fc2-4710-a805-4fdaeccee75e","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"821baf21-dd8c-4bbe-8b81-3267f13f7fca","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"b737d473-1d85-457c-8513-068418462945","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"7988b8fb-5f7b-4c12-b1e4-b7fcacf62192","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"740c1a09-62ea-4b9d-88ff-969657b19b86","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"768510be-1fda-47ca-956b-4e4a0106b1d7","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"b293fc1a-7eb8-49a4-b087-dee7512a39f5","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"c07ea0d6-e4c0-4523-8f11-0fe80b7c09a6","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"d9d18643-ace0-49ef-9f41-0b24a7ff5411","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"3aaec635-873f-49d9-a999-14a1525ef15f","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"e837d5d8-88df-4db0-920a-bec04dffbabc","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"1230fb37-6e5a-41d0-ab23-20152046583c","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"075aed91-02bd-4356-abe5-cf645358372d","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"5510189d-6bdb-4cd6-bd7e-31d93c2e44b2","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"cbddef6a-b3dd-4205-b34e-781e850af7c5","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"0a1271e7-56ff-40eb-bc9d-5d73cb9bb891","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"3793c941-c5eb-4a35-8b9f-f656ee4394ab","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"9243bf35-cd4e-4190-bdf5-68ccc06730e9","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"98dbf170-ba3d-40a3-b7b4-ae30f0790be4","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"4684633a-542a-44a6-bd99-2b88decd5ed5","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"d1df2431-74f4-487c-b62e-e1ac7707bfd6","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"ac1de688-8d1d-47c8-bc9f-cd1c75303f18","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"421d60c7-96a6-4058-b805-3406bb86f9ff","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"971d7ce1-2de2-4c22-9868-446a537a9969","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"e6e261bf-6b5c-4e63-83d2-82d61df0c6c4","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"9c91ccc0-7f42-40a9-91a0-2bbc4b9a96df","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"6f582327-5d83-453e-9da9-56af09e7d668","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"8a8bfa37-2c2b-4abb-8920-5b5e09b7dcc7","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"5545aef5-253b-40a0-9373-48a0c70ad743","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"1ff1b779-5221-44fb-badf-37a0a6a9a080","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"2f145582-630f-4437-bf86-c5a87b0d4b65","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"5a31525e-1cf2-4074-bc2a-54aa7b49325e","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"ce231ddf-5dcd-4e68-826e-58d167612f8f","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"6663d126-35a3-49f5-b327-bbf6e5ec74a8","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"b36d383e-b6e0-40e0-8210-2cf116a9b7bf","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"a62b8e3f-6c09-4107-861e-b09189d8fcac","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"f759cf81-fd8e-46d1-ab07-2ef51d6b373a","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"f5a2c491-1ecb-4c4e-9673-7e77cb57ae58","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"c583d3ae-c745-4b25-a4c7-b4284c33595d","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"00a3a713-b0a1-4e87-8c05-0655377f83ae","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"1a139d24-1c7e-45a2-bf64-eed2368f0800","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"86040393-e3d2-4537-b4e1-cc1506a35eb8","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"5d02d518-06b0-4675-907d-2df6fa306c04","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"7bc0c93f-49a9-47be-883a-7ca9c348b1bf","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"43f78a2d-27b3-410a-a053-dfb04abb9ffc","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"0ae5ddc5-bac1-4382-8c29-c83b19ee497a","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"773a394d-d6ab-4744-be08-59b2fc3f86e9","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"9562f36d-0ca1-4ef1-b029-9b45e1aeb662","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"e4684e12-2a49-4029-bc23-158eeaf45988","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"01369920-d58a-41ad-9acd-807b28175ecf","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"d636ed6c-c6c4-40ca-a8ff-67b644fcd19c","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"05003cdd-6eba-4b70-9f68-07603257a1ff","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"67bbc8b8-5b86-4c2e-b4ff-bb1dcb943d3c","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"53718249-6ffb-4592-b070-252d77ae5fff","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"15bf534b-994e-409c-a8d1-68ccb6472ba9","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"8d884866-7192-4605-ba43-fda9f8826bc7","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"e858f87a-0129-4212-a706-c7813f26b8e2","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"666eb873-9b0b-4160-8b4b-0844fa11f0e4","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"e6fa8b35-aeea-4d5f-a593-4f79beb49d6d","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"2418b083-91f1-4049-b739-9fffabd78aec","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"4bbb171d-0b54-43e3-bb36-f743fcba4225","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"1e59ee4f-95f3-4ddd-813f-fdc1b6467640","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"414aab9b-67e7-4907-a000-f3d84294e800","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"bfa8c44e-5f30-4d90-b0fc-0bdba7cf65e2","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"51206f40-6069-4ea5-980f-939488212d0e","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"2c871408-49e3-42a7-adbf-428d22d76366","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"f074328b-9fd4-4ca9-afc0-9ab57b07decd","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"38fe96bc-12f9-4dd9-b585-3ee088930626","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"98178962-0d81-4266-9bd5-d225b4ecd375","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"bc4674b2-e87f-432c-a025-b05afe22eb23","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"f011a8bc-cdfa-4574-b44b-a053c1841ac6","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"95c78511-94e4-4fcf-b02d-963ac8be14cc","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"5587f056-dee6-4058-adbc-c5c0e83f73c8","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"ffc45ae0-783a-4661-99af-e1617bfb44b1","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"ee127563-e3f0-4543-a61e-044f8c5dc9ea","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"0b676d2e-5847-4271-ae49-a66676ff2d26","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"0f283ed9-6baf-46b2-848e-b8e86662e4f8","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"525fc098-e5dc-4759-babd-6f13e1c7c15f","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"f620ec73-a71f-43b1-ac84-8c2738ed1b34","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"06f4108d-1aad-4a82-a2c9-7840f2047223","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"3617c94d-ecdc-4a91-b320-8e04a7d6f02f","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"7abcbba5-5fc8-4f85-bc1e-d9fd9ea1d40e","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"0b6395e7-1bec-4b7d-8392-00c4227c1257","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"1a290518-14c3-47ea-bd40-a8b2ebbc545f","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"98fd595b-4bbd-42c6-afab-813ca7b9b953","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"15616fb6-b738-48b3-a30b-9db86569023a","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"eee68800-9595-489d-9ef7-06901e2d8d0c","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"a6a2f15d-73fb-4ad0-b315-311a54326c49","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"422246cf-c303-46b8-9ff8-1c6912efcc15","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"3666e604-ab53-4514-81c7-f72a2d2fbfd4","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"44abfee8-e938-46d2-aedc-5c1ae87742ee","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"db011eb7-cbc9-40cf-8d31-974448fd777a","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"18a59cf3-4438-4aa3-8d3f-d4c519fce4fb","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"687a47b9-b690-4759-9ad5-c05277e2541e","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"65698542-d72b-4437-9f2e-f7b832be614a","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"76fb3342-c8c5-4eb6-8f34-55e0e203a548","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"f7e08130-c451-474e-84ce-9302ac9e3e2f","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"a758aed2-f165-4bfe-b042-e1895e187f59","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"88cbbf85-6259-495f-95f1-1d1663033db4","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"cafafbed-a638-4182-b0dd-a2e4991985d8","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"491f9a54-a8c8-4705-ba07-3c4705d9172c","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"0c4676f8-c32a-4048-af46-ba089cad75ed","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"63bbc8d4-536f-4f81-ad6c-639af18adab1","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"7d274315-c1e0-4f3f-b920-7148c154ccba","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"bdd351b2-ce0a-48f7-92f4-1ce7d1b01db7","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"c0dbfb41-5158-4104-9c2c-523ca52bd803","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"f66fa0c0-186e-4960-b214-656c3016264e","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"85977857-2ded-4d7a-8e86-39e07c2e5c5b","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"72de1db1-0272-4be2-9103-9803639464c9","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"c6f7d186-ced7-4917-8157-9b3816fff68d","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"0e4c5a4c-82d4-42dc-a0c0-860b491e73c4","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"c76db50b-3468-48ff-90d0-f3c79d519cee","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"57f929e1-f80b-40c1-b999-a3fcadcce63f","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"8e9bb9e6-2b6d-46d2-bf0e-d780a40ffdd7","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"e76be061-26c1-401a-bb06-b734c3c61fa0","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"e6ca7149-0dc6-48c2-9f21-1a418bd2440a","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"4ecb4f2d-bc87-4bdf-b5ac-e76598a349de","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"988f24a9-86e9-4481-965e-f0d73e184624","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"a8edcb2e-c293-4f90-8fe4-6960e04752ce","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"04b63dd8-f14e-4839-88a7-3d252609433c","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"377b783d-9c4b-4911-a868-df87ea9b5e2b","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"4dc8194d-fed8-431b-a96f-37dabaf8f391","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"2814fcb8-689e-4130-b395-d61f1c9fa116","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"af261734-9333-4a54-9645-d471e8d8eeac","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"00380203-fc0b-4a0c-8a85-1faca650d499","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"9250bc05-6ae5-4761-8f64-04acad302b1d","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"6c215469-26ec-41b4-81d6-33db3af9b358","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"6996969f-50bb-4530-b573-d55e0e6cdb74","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"c26bb5d5-b0b4-4623-aa69-c5f03f68088c","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"4f252a6d-e1cf-4e9a-b6ff-20c5a42a0660","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"a57249ac-c51c-4bb8-be05-5633b1ee4cb4","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"5803a1fa-2167-4868-9808-95d4457a76f4","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"5d68c75a-9afa-4595-8e2a-34d6217dd787","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"82846a71-1e63-4370-922b-56a9b7c33578","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"c3c9d8b1-0574-4fcd-b471-530b45dffd65","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"fc9b2934-27b7-4dc4-b6a3-e76007e5c9ec","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"947180d6-2461-44a5-a37d-1290ca8c3c2e","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"a62f5b9a-2217-47ce-b5f4-663b27a31ede","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"a65c2fb2-7973-4ed1-94f7-43924de9a848","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"46943dc1-0304-4a79-8fea-8dbeda52ef1c","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"5283d600-30fa-4944-a1b7-a5053919a23e","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"52ecb06f-2819-4909-b20f-d7d3c15e457c","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"ed2ec464-b4dc-444c-9f5e-09c7948433c5","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"22f5a29f-e9ef-417a-8a65-2378f699f5fb","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"8f4750ee-2920-4ee2-9691-716838c6cf97","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"238a4f61-3ae3-4d6a-b888-b873fcc1819e","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"b811afd4-8d0a-493e-9ff6-db23d768badb","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"5986cda0-2131-425c-8535-6ba22b9e5e46","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"9c860673-d253-4a2b-ae4e-4f322b84236b","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"ba6144f0-00fe-4249-8978-e8f4d90d18d5","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"d1f408bf-d70a-4789-9102-d85fcb04a8d2","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"e65cd024-f5e8-40ae-bca6-51ef3b466cd2","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"12034095-c240-497a-abfb-4588a75f7ecd","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"b30d32c1-1a9c-4077-8427-d6f279d5dadf","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"971663fb-d63e-4b1e-8b7c-f120afc156e7","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"341bc4c4-8254-42be-ab2c-6d58bb8a16e2","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"52dfa009-c77d-48e3-b30a-178dbbddea55","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"c9c739ac-0c26-4967-a399-9a5ba7afde57","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"e54bd605-4106-45e0-af0a-011c8dc2b81b","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"a2a93669-2770-4d18-b11c-2ccf9ae119f2","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"042d4ca0-a5f8-4396-84a6-9218b0c94426","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"f236cee9-f230-4487-aecb-0b0b6407b558","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"f2fdd221-f27d-4499-bc3b-ae1e9a5a17ca","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"5eb499a7-db14-4c1c-8e82-b8cdf13c4deb","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"da96ab84-1979-472d-800a-f6195a5a8540","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"859c98b5-a9d0-4638-8a15-14414c8fedcd","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"8ad12cc6-d54a-450a-8c02-22b7988c6d1c","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"d4bc2cda-a50d-482c-9a03-5837e54c0ddf","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"35805b88-2bbc-4a4b-86ce-d28a6ae114ef","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"26c84132-8cc0-48ec-842c-14613642f6d1","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"59169323-644a-49eb-a832-a3b07a4feb01","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"b7cc0908-64dc-4a5d-aa90-f649aad99b4b","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"a3eb8295-70cb-453e-b033-3d5141c216b7","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"f41236e3-5350-4e94-90e0-f723d2398f0a","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"67de73d7-c8f5-4c2b-8fc6-0d9adf72638f","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"23aba190-7cd4-42be-b9f1-c7d2c515ddfa","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"da615412-c386-4cd0-be90-9d136fad7847","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"e5ee876b-a37e-4758-9bac-cc4e0396c90b","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"fdb2055f-112f-4a59-9c05-6c3a25c47cc0","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"f119cce5-e0c7-44a1-9104-0743ecd0a29e","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"43c62b65-a40e-4057-b771-d4a152d3f84b","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"952a17ec-92a3-4b83-87b3-ff43a977ccd8","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"d209cc8f-3f30-48ee-a2f2-fa24d4afd5db","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"ffc6e38c-6d29-4a6d-b3e9-38c200b7a377","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"1dad4fab-cfcb-42bb-bba2-926b19fd9b2f","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"c60bfd06-1d1e-472a-8b92-8d8cf12cc3ee","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"c71607f5-a960-4980-ad44-2dcc336933b6","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1}],"received":1477840946572}');

INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RECEIVED, DATA) VALUES
  ('03742ac9-d5b6-4cb2-868d-31dcf56b92aa', 'b222aa15-715f-4752-923d-8f33ee8a1736', NULL, NOW(), '{"id":"03742ac9-d5b6-4cb2-868d-31dcf56b92aa","groupRatingItemResponses":[{"id":"d2d20e31-762f-4a0b-8334-a1e4b6aa7811","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"2d95510c-e371-4c04-8164-bf2a4c3d231e","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"7502da57-e846-4a6d-91e6-6de39e6bf766","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"2dabbc61-79fb-481a-976f-6457a603398a","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"b61cacc3-4c54-4954-a78e-69f7c55ee9cb","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"8d125202-876a-4990-bf20-c6e20d26a8c4","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"fbab5434-249d-496f-9cfa-58cd7aee3dcc","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"44a649f0-e1eb-47dd-b96f-2dc6c1a95ada","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"e6a05560-d72a-4ece-8ebc-24ce6b254250","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"fdfcbead-460a-4903-9fba-d64c8a04e653","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"07aee92a-bd98-4773-a8e9-0fe50928b981","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"602c6870-1dc3-4383-bd9e-d1fa6e86da83","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"574089d1-b425-44fd-a041-f6295f1f2943","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"45d2aa65-be9c-4fe6-9da4-378158b3f34b","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"5b9562a1-2aa5-4fda-8823-94720e1d03e9","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"ac585de3-94d9-49a7-ab89-65c0532493e6","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"b9d8df58-2648-480d-bf83-94c6a74b93af","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"3d318c17-d6b4-48d0-9d2e-75171ac65ffc","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"325ce9d0-4935-4c8e-8faf-4aa5c0d2babc","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"cb47123a-39cb-47d8-aa4b-26b1b5ed3ac5","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"1e658f0a-0c57-4bc2-a1fc-f1937515203c","groupRatingItemDefinitionId":"075fda78-78b7-42d9-be22-7437ac7432d3","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"379e050a-861f-43fd-a0e5-5c5dfc06335d","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"2ebe16e7-f239-406c-bb40-493872d53a2b","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"1484212e-8f98-4d17-9150-85f67a84e2e9","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"c1889b70-7a49-4df1-89b0-80dd2ec6ae48","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"176d26ec-e226-444f-ae36-4f3e86845e61","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"cb805c17-0e04-4e18-a20d-08628f627bf4","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"fb10a50c-fe75-418c-b47f-339f1e17a99c","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"26d3fc1c-230a-4ccf-a05a-28e335493f85","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"feecf236-9c12-42c1-8395-075a86e8c481","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"2366a007-8135-48ff-8eeb-25cd5ea3f36c","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"6ce0a2a6-2b5f-4b1e-9e4e-c290effc10b3","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"5526c3b3-5933-43a1-815b-95575bc7bf93","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"9c56452d-7ef5-4982-bf88-a9f918f1bbc9","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"eb4c13ca-ccd5-444e-9ad0-46b1cacc978d","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"0a68ba31-d84e-41ee-b41b-509085e65656","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"db271035-64ca-4efd-ba9a-e36cd9ddf257","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"fd0114c1-edf2-4ccd-bf38-0a601933f3a9","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"7226e92e-56e3-4e9b-a764-582038528c26","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"d0b778df-b29a-448c-ac43-207ccb160244","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"dd5ac83f-c78d-42e9-8064-ef2658bcc83c","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"186ed75f-4292-4ce9-a1d0-d99c56bcf353","groupRatingItemDefinitionId":"90d78705-4706-4d28-a4de-bd56de443c22","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"d15b38c0-1f14-47b3-b8fc-9be80ed9a6cb","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"de45c94d-f192-49b1-a40d-e5580d9494da","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"fdfa4540-ee32-4a05-b61a-38f3c8ee2863","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"10014943-95ee-4e6e-b8c1-0328cf9bf29e","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"f0042f8b-ace5-48ab-bde3-fd8f044c7ca5","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"f24e7860-bc31-484b-98ff-eb9d4b74a339","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"24b59038-d9b4-45b0-8e46-8da692024a3c","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"cb718a42-d91c-4277-b937-289198fe828a","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"c9cb5d94-69f6-4670-9965-dc80dba4c7b5","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"7f815876-542d-4343-858a-d48685ddda54","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"eba78c95-e4c9-4177-88fc-fa890affbc40","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"810ec646-a020-444a-bea7-8717f710475e","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"99b0c2bc-5953-4fa5-a22f-028c41ccf6ab","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"f19d09c7-9e94-4fbb-834b-a97e7cb03ecb","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"8f9a10bd-d819-485e-bd6a-6a53efab6224","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"529d2a3e-a7d3-4dec-bd8e-72cb8075db1b","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"9a4432ec-d22c-4b43-a3bc-cbc8afc73be4","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"b918a1d8-812f-40a4-8172-6064a0302820","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"b96b9ef2-f068-4148-bdd7-43e7f0bf93fb","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"2a793042-b2a2-4eeb-9d6d-44c0bc6b24a1","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"4b980bd8-6784-4826-accb-1d6be6cc5063","groupRatingItemDefinitionId":"ef3e49e8-732c-4333-98b2-404977a11c78","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"ebd0d4c3-945a-407c-9b89-bcbed94cd42c","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"38e3c432-3ae6-4095-8dbc-1bee250d3777","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"04c4a9da-561f-4963-b2a1-ce093fd5d01d","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"ea143b9e-cb05-4a11-bdb7-1ee8f3c76cdd","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"59074038-872c-43e9-88bb-4c6b02afd56e","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"1abfe023-8fe5-4dac-b50f-2e43dc82902f","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"e4c8f1f4-aacf-49dd-acc8-4a6072aa1e61","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"ad17004e-4295-4e87-aee7-7209ea856778","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"16123497-2563-4148-bd25-6e029e18fb00","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"a3a100b6-629f-4484-8f53-21c2bbbd62f2","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"fc239e42-5ea7-48df-8002-1550b27a0590","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"059501a4-6d2e-4d49-ad6d-f1b2db6c4f97","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"fdf6386b-26a3-4c95-99cc-178dfcc0d700","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"cc7c1e67-d471-4d19-b8b3-3e4796404973","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"39b17ea5-ff58-4c21-97c7-a90b9a0d182a","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"65e133ef-4038-4a7f-b4ea-5942f74c0aad","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"b4afec87-8dc1-4338-8c2f-f336cb62681b","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"63614ad6-1804-45d3-b93e-3f6106564ea2","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"d5d8b6d8-2d2b-4056-b5aa-24f9e570484a","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"d54dff67-a4e4-4617-b923-877e9ccb6576","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"b26ccd39-1b89-447e-b5ec-d1a3d7425c81","groupRatingItemDefinitionId":"27de7999-55d5-4248-a23d-d1bd792c7057","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"1ff7213b-c52b-442c-874f-855e4deff1eb","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"70984293-a094-4bd3-976b-ee100b593702","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"343541c3-bdf5-4851-9856-7d62c6fedf59","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"b1088dc7-4710-4457-bfe1-9d844d7fdd94","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"cad0e012-cf92-4211-b7ce-1910c8000653","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"cd98dd46-1b9d-4f55-a1fd-19f4b3589ab6","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"07f44815-a254-4704-8e0b-7c91276ce346","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"eaee0c72-e5de-4dc8-9cbd-c9bf1e3f36f5","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"72920be7-719c-462b-a913-f91d0fde5348","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"8564a6f1-4eaa-4344-8faf-116d61fd46ac","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"b2ba370b-1e44-410c-8ab9-4397717f2a90","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"ec4f35c9-9751-438b-982a-33983fda42c0","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"4f4fcbac-f82e-4473-ba40-5a261849a48f","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"865205bb-632d-4ebc-b28b-a5ac0e9d79a8","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"da1fe226-7812-4311-85b4-f8bea8029dcb","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"c4f31b7d-14c3-4862-97a6-8030f3cffaa2","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"e39ea0a8-3b9c-4f7b-9f48-e640c3322368","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"a30f1d17-9ffc-4b77-8933-3a059c595787","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"10362fcb-3a79-4ab2-bce0-f5a2ac813157","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"cf6522ba-cdec-4c4a-a48e-9a216511d21c","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"2a4463e1-1f9f-434c-81f4-72d7f556637e","groupRatingItemDefinitionId":"169e4cd2-1779-43cd-a42a-722edcd4384d","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"24f5b830-8a9f-45be-8ba8-1272af2bfdbe","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"b65853f0-c8e8-4727-999d-6750751321d3","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"47d8fe23-2ef6-45c9-afa6-0d5ff9ece25d","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"12078ebb-11fb-4172-a7e0-30a0cd09ff46","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"21813b43-7045-47cf-a9e8-0db067a09988","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"493acd28-6efd-48ab-8e82-ebd1694242a0","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"cc3ef8f9-c57d-4248-a29c-1730b2c49202","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"1de11844-945d-438a-9a24-6e1141603f9c","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"e2d75987-3fd9-4e2b-a95a-dab265260b78","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"1d4ceeff-77da-4e55-a81e-793e7ae12448","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"87f6da74-84ba-4a2e-9e2b-d038e5624edd","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"ef371e58-0e33-48e1-85f5-e9a6c9af095a","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"af613912-f996-4cca-afcd-e85dc1782958","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"6239909c-04ad-4650-a12e-9a16804d343b","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"3b2b82d5-dd2a-4c5e-b9ba-72133478b91a","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"201e4c99-1951-4b81-a459-6383bc0d72ae","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"768b1593-c561-4f5c-bf72-c0edff2fb831","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"bdda2191-1874-45ba-98bc-9660b67cf2ab","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"65025146-d022-4598-b867-e3435c2a543a","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"0a2cfdce-b924-4739-8727-1ac230454b69","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"333ac2e1-63ad-4fb6-872d-06af500f2f81","groupRatingItemDefinitionId":"efef294a-3011-4828-80e3-47a29abf2432","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"13c77d5e-8814-4681-b193-93669a626635","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"930c1ad5-c3a0-41a0-8bb3-dd102fbe1e76","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"2fd583e9-ab13-4196-87bc-ec6e9355efb9","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"e063a180-5af4-4e6e-81e3-b2a8b2f9e08c","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"4d599bc5-3b3e-44fc-9ce2-807c845df334","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"b3cdde00-7307-40a3-a9d1-764af8f21791","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"23cdf215-69d3-4751-8f9b-6785297a2b7f","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"49c47b93-dd39-4e14-9b84-23c66dd087b8","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"74b1ed0e-70d9-4d64-9511-ef12cf08bdd1","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"c770f94b-de07-4281-aa27-2d77ed1d816f","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"7ba8085e-e0fc-4ab9-a6b3-75d467825367","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"1e6a3df9-1cad-4312-9e9a-9927afa6e930","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"b539bccb-c94f-475e-bf85-825bb647a49b","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"b40d2da5-6ac1-476c-b2f2-e83a8c19028a","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"6516aa33-eb10-4da1-ad32-6ede09ee78de","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"c78f84bc-0c32-4c95-a465-c068efc02e24","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"c9eb8203-7946-488d-a4a1-eeb696831bf5","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"959fdc9c-a643-4f52-ba0e-eb8c37be4a7e","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"76be31ce-5ac4-46f9-a352-ae1bbec66cc7","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"c1b35c52-dfbe-49d3-a9fc-9d927d4d5a10","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"830ede2e-4379-4413-b466-3295f3e29490","groupRatingItemDefinitionId":"7fcca30c-9f70-439a-9822-a4b2bf41d4b4","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"08efc1cb-8a47-43e2-95d9-bf44d7604dbf","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"279b910c-1465-48a1-898d-b402c4040d0c","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"782511ae-9e73-470e-a7b1-701d91d96597","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"c423e528-31d7-4d84-86ad-c4e05baadb71","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"29e2829d-4aaa-4b3a-a0c2-8c4d7814e0d1","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"8618be5d-0d3f-41ee-ac9c-4c79e12d23df","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"ed99e55c-b109-4376-8883-274488b94fb6","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"7883febf-d62c-4d60-ad55-a052e4fa219a","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"d312d62c-230d-463a-a012-2c9ca6184a98","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"0f57a1b0-e963-426a-9d1d-4e3e79b45a19","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"b3005bad-4a5b-4205-b851-5c8aa5c7723e","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"c6059e02-27ab-4896-b31b-2bcf4fa24ac3","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"b6cd6d9c-88e9-461a-ba18-51cc81f22e73","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"646ab460-5edc-4b8e-91a1-2481ebcc750e","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"b3426288-976a-4630-8c7a-e3b05a837d64","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"b24bf8cb-f6b9-4649-9962-d4eb50edd227","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"c52770e5-2396-467f-8e61-dbb7b4b6aac2","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"e5cb225e-756e-482d-80ec-604ba7a9a98f","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"cdd75984-9dfb-4c04-be65-1e00a82dd9c8","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"45bb7eb4-5885-42a4-b753-46ce7f506103","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"3dede042-68c7-4764-a16e-3f8370ae5ef4","groupRatingItemDefinitionId":"d3917e33-19dc-4ee7-aea8-7b7b8528f81a","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"825b22fa-ffc2-4b5d-90cb-212318bbfe3a","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"4560381f-d3f1-49b8-824c-60af486030fc","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"464ceafb-3d73-49db-b2f2-216070588d70","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"96395731-0ed9-4078-965c-e36ff5e00f73","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"c1ad11d6-9d43-4638-af7a-ed1aad90cb16","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"ddecce5b-50d2-4178-a088-188cf4df132b","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"21e43133-cfba-4cd9-ae88-40cb0a4fbd14","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"2634a1e4-96c6-4926-b045-2dafca3c389e","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"b0ffc264-e1ef-4017-990f-c33f08edb086","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"47243688-7b21-4523-8f62-ff131ff9f626","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"05396610-4a01-4cef-bba3-f2568d265a5c","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"73a71cfa-3a88-4487-b473-a1ce050e2717","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"11f21924-8185-4a8a-ad06-100549a3e735","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"36029085-5f4d-47a1-aa79-8d342f679c79","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"0589d688-785e-4145-bc47-d8848f5ed850","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"0d87437f-70aa-461e-8b51-aedd579cd34c","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"2c673e67-16a6-46a5-8d81-3ae4db188ed6","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"f943bd6a-d3ab-44e7-ba33-588d9eb6f7b6","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"3bde0a21-7bde-4908-ab64-57e7108eb0e6","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"97a1a9a2-cd73-441e-92a7-4afe99182f9d","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"d7da5064-9450-4acc-9d25-93b592221f44","groupRatingItemDefinitionId":"e131f4bb-03dc-4162-87e8-8a7d06540300","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"83ec8371-b3a0-468d-a451-049eb4914e05","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"88a0f5dd-5bd4-49b1-883f-715a4d32a107","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"6c7ff76d-a5f0-4215-9c73-e7af165b0447","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ccba3a1d-9304-4744-b941-b3fe6213a31d","groupMemberDefinitionName":"Peter","rating":-1},{"id":"be587313-9d35-4bad-a8b0-bb4b5c1d8371","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e932f49e-4d02-40a8-9349-ca7897b73f93","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"45115d6e-0bc6-4a21-8507-96b9e55a5165","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dd2755dd-e127-4491-a587-fe8bc493cec3","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"cf81a88d-7472-4f1f-99e4-67634b055155","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bfe364a7-52e9-45a9-b87b-55a691004290","groupMemberDefinitionName":"Dan","rating":-1},{"id":"216afea8-6025-4a6c-aed1-c69b702c7782","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"48779544-f486-48b9-b85f-15a87124ec23","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"9bcf7296-dafa-4bae-86d4-8aa1714cc095","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"21663954-6a28-49c1-b69d-61168968a47f","groupMemberDefinitionName":"David","rating":-1},{"id":"070fcbea-ea48-42b7-ba8b-39d18eaf2e75","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c4cab476-1afa-47bc-9935-e9d6284f6e6c","groupMemberDefinitionName":"Francois","rating":-1},{"id":"f3fe8323-697b-415b-bfdc-cfc2d0695df1","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"16c64306-cd5a-4ba6-b689-448e5ffaf18d","groupMemberDefinitionName":"James","rating":-1},{"id":"8c2f6c00-bfa0-4dff-9d29-16f817fb016f","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d1114357-f62f-4ae5-8237-a8bbd0e775eb","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"8012f936-6485-45bb-b3db-0b63a853d238","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f3ec42ba-989e-444c-8981-fe7193b32b48","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"30eb5097-5a75-4604-9112-b8d1ab0dd43b","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"d55395c1-f012-41de-b2cd-9e784ce35284","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"be59f089-940f-4c27-a959-4708a895e063","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e45664eb-67b2-4ba7-99ec-0eaf19cd8eff","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"e03eb812-fcdb-4152-b402-24cd72a51bca","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"fdb51cde-a0a2-4ab4-bb88-4ddec59ab2af","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"55d2fe1d-4dfe-4872-b1b1-5338eeb7f4c8","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"83fc7453-7024-4f42-9b1e-ef5917cd5a2a","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"bcbd779a-b671-48bb-8006-cc686238bfa8","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9cbf5c5b-cc56-473d-b4cf-432498a6a067","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"d6b441da-0135-475f-8d74-33237b5c561b","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"34bfa5dc-3ee8-4ccf-92ff-6db7bdd33b06","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"def0c69d-8e50-4402-bb99-d55e1a566b8d","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3e4eace9-6745-434e-b29b-3762cfe0084b","groupMemberDefinitionName":"Richard","rating":-1},{"id":"f977c2dc-3ef6-4750-ac4c-906bbcbf6026","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"db6d9c02-c4dd-40db-8b9d-9a8d9b8ca163","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"d7ab1894-61dc-45e3-ac0e-6558d079509c","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"dbba4a37-0922-41b6-a9c9-bfc45df466c4","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"b8a5de7b-eecc-48c4-be94-62d57400e0b3","groupRatingItemDefinitionId":"f2d5236c-9564-41cc-bbd5-2d47ba7d28c0","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8186686b-e845-4ce3-8d81-fa97dade814e","groupMemberDefinitionName":"Debbie","rating":-1}],"received":1477840946574}');
  





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




