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




















INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, ANONYMOUS, DATA) VALUES ('706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'd077425e-c75f-4dd8-9d62-81f2d26b8a62', 'CTO ELT Values', 'CTO ELT Values', FALSE, '{"id":"706fb4a4-8ba8-11e6-ae22-56b6b6499611","version":1,"name":"CTO ELT Values","description":"CTO ELT Values","sectionDefinitions":[],"groupDefinitions":[{"id":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","name":"CTO ELT","description":"CTO ELT","groupMemberDefinitions":[{"id":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","name":"CTO ELT"},{"id":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","name":"Peter"},{"id":"2facaf21-3969-4840-860b-632ab3bc729e","name":"Adriaan"},{"id":"babb428e-a6e2-4a06-9258-f776a9d6a818","name":"Alapan"},{"id":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","name":"Dan"},{"id":"b3388169-2369-458e-8fad-66e791e897a4","name":"Daryl"},{"id":"4c112f21-c002-43b9-827f-7414dd334937","name":"David"},{"id":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","name":"Francois"},{"id":"e849883a-ef72-4902-9246-5d3b5b0df9d4","name":"James"},{"id":"f22c2dd9-47c8-4071-886c-7b0164597ef5","name":"Kersh"},{"id":"1395d417-c201-4f87-b2ed-5dc41bd68821","name":"Kevin"},{"id":"c9075011-d31e-4104-9f0f-288011187b24","name":"Linde-Marie"},{"id":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","name":"Manoj"},{"id":"90653250-746a-40eb-b249-24b67b43b231","name":"Marcus"},{"id":"97d0753c-35b8-41c9-82f6-61b438ebba53","name":"Mercia"},{"id":"4a135226-7a3d-44b6-8218-c96295fae93f","name":"Nicole"},{"id":"90f92a27-b135-496e-821d-d13fe11a1e32","name":"Lawrence"},{"id":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","name":"Richard"},{"id":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","name":"Sandra"},{"id":"9beefe22-7b8d-432c-b19f-55ec05036703","name":"Tendai"},{"id":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","name":"Debbie"}]}],"groupRatingItemDefinitions":[{"id":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","name":"Accountability","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"a6548403-e8db-40bd-9076-ecc3412c99ce","name":"Competence","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"34f4d372-fa72-4309-b7f0-b3531851511f","name":"Courage","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"dcfb54c9-a170-4027-b0c0-963ff624eca8","name":"Fairness","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"f3020302-7aed-458b-96a3-02ec33f126ca","name":"Integrity","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","name":"Openness","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"f609873a-30b4-43af-9514-ba9a54919250","name":"Positive Attitude","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"69f9e11a-eaf8-498c-a959-c7b312e45598","name":"Teamwork","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"1db206bc-60be-4bcf-af83-b907cb9ac534","name":"Making a difference","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2},{"id":"9482b46c-c207-4df7-8cbc-0bd5c1942902","name":"Trust","groupDefinitionId":"f286ffb2-e1b6-4058-a0b2-0e124717e58f","ratingType":2}]}');

INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME, DESCRIPTION) VALUES ('b222aa15-715f-4752-923d-8f33ee8a1736', '706fb4a4-8ba8-11e6-ae22-56b6b6499611', 1, 'CTO ELT Values - September 2016', 'CTO ELT Values - September 2016');

INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES
 ('54a751f6-0f32-48bd-8c6c-665e3ac1906b', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Marcus', 'Portmann', 'marcus@mmp.guru', NOW(), 3);
INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES
 ('215640fd-ee60-4f66-82bc-d173955b2228', 'b222aa15-715f-4752-923d-8f33ee8a1736', 'Aiden', 'Portmann', 'aiden@mmp.guru', NOW(), 3);

INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
 ('18f3fcc1-06b2-4dc4-90ea-7a8904009488', 'b222aa15-715f-4752-923d-8f33ee8a1736', '54a751f6-0f32-48bd-8c6c-665e3ac1906b', NOW(), '{"id":"18f3fcc1-06b2-4dc4-90ea-7a8904009488","groupRatingItemResponses":[{"id":"0377e564-3ce2-42ac-894a-e610ac9e3385","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"6538801d-bf58-41d3-a46d-60a5f001360d","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"74137ff2-2098-479b-864d-8d7a871388e0","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"14d71126-2f27-441a-b6e3-8434cfc93e2c","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":0},{"id":"3a122a3c-dc0b-494e-b9ac-5e3822bddce4","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"2b6d498a-6345-46dc-924a-fb730a9d9ee3","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"bf6bf4ac-e2ea-4275-8bc9-26c7d5fb42b4","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":0},{"id":"4b877f20-fba2-4c05-89df-8c31ed186929","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"995fbd03-5500-4779-8cbc-0624171c006b","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":-1},{"id":"7ca0ca81-61bd-41ae-967f-ccb6d916eb18","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":0},{"id":"31fd8f16-4c48-4b9b-a8a6-f2e4ea4ea8a7","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"af01e540-7dc5-4417-b81b-6579ea22667b","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"a4feacd6-09d3-42cc-bb74-7a92913faf90","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":1},{"id":"ab8315ed-b8bb-4eda-bdd6-ff99b356f711","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"cb86a470-639c-4ff8-9722-e8488d014a2d","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"60508bea-d577-499a-9d2d-9c43fc574787","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"ca02f118-b248-49b5-a246-519c4610a14a","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":1},{"id":"738e47c1-649e-4a42-8c6d-fa98c4dd3117","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"06d87b43-fd93-4a22-86db-c4380353c331","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"a1218e7b-9bd4-478c-bb22-b2c6c8446a55","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"a3a54b94-528b-414e-a80a-2ed4c98bec00","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":1},{"id":"4a4ea200-b255-4731-a048-982c1b147b58","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":0},{"id":"76d8448b-1ec8-48af-a100-0cc6fb9effc7","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":1},{"id":"f32cf4f0-eec0-4ac1-80a0-98f642bceeb7","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"9554d97d-ab86-486d-ab68-e8e1ad8187b4","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":0},{"id":"c4cd377d-ae93-4cc1-ac4e-e335bf9d6634","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":1},{"id":"04f10328-56e2-4d20-b351-6f5d5352d374","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":1},{"id":"3ee502b0-b080-4e73-867f-53ac8af3fa2e","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":-1},{"id":"47a242c7-026b-4a6b-b5a3-1fe7734b70f4","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":-1},{"id":"ed0efef9-154a-40d8-a1c7-56ebc1733da9","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"f2f4101a-1699-47f3-8638-17a296831071","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"1e043f49-d163-4bae-b867-7d2cf7d063dd","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":1},{"id":"6d34b90f-b4fa-4abf-8311-80f3cbf573b4","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":1},{"id":"49c3c36a-1ded-4149-aea0-24a72b706796","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"1b37997e-fb32-45ee-8d0b-9157af5bb260","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"7a4f387a-15bb-4a49-bc5b-e825cb7959e5","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"66b0f930-6a7f-42d7-a3be-2d7c06f5ceb6","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"50ff5638-8795-46ed-833a-295de20408df","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"d85a86bd-cb90-4239-b1be-6f81af933f6f","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"ad63dcab-cf7a-4ac6-aef7-15e75a88b3f8","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"09f1679e-4643-43eb-84d4-c0f7c5872de4","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":1},{"id":"19810fbd-cb7e-48fc-87a3-2662d8bb4855","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"d709baeb-c472-428e-a40e-b08d18a9bf97","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":1},{"id":"3eccb32b-2af5-4a7e-a722-9a0df1e62b13","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":-1},{"id":"695aa6eb-7950-4073-a4ca-3b34b8d6c979","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"a169b810-b14d-457f-8ddb-e6eeadeb214e","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"8d9c37b4-9453-4ce5-9788-8ba1b48c3c83","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":0},{"id":"61d1e77c-6748-42c8-b29b-7b916ad5b367","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":1},{"id":"95d1ff6e-cb83-4a6f-9fcd-9116b617a478","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":0},{"id":"8850982f-e0c8-40ab-8f5e-4b790309a673","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":0},{"id":"ead8c38f-9efb-488d-aeac-a33da866710c","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":0},{"id":"ea2376a2-6289-49aa-b87c-1d977dce8c9a","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":1},{"id":"12262135-8ee5-4ce2-abfb-5ae21c959165","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"64ec2305-869d-4c6c-9857-4efd4c32f6a2","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"3777be85-8f1f-4cd9-bd26-da678023acce","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"eea81d37-1ab2-4449-aa57-0a94d24ed89f","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"bb0d41e6-3e35-464e-995b-dc5f0b3165d0","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":1},{"id":"96af3945-47bc-47a8-a49b-d01e7b519e48","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":1},{"id":"05466f6c-f061-4e89-bd25-2def3de324ff","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"218fe592-77c1-4136-8f38-4c980144cb10","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"8bc0b5cd-5ecc-4312-8406-9cd036766be9","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"dabb703c-e90e-42e2-994a-2d6a9b3c4cbf","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":1},{"id":"9ef2ddeb-7ebd-4c31-b4a4-0972a331a7cc","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"21bfaf4c-546f-43df-9339-867adf1a8603","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":0},{"id":"80410f55-6477-468a-a643-a2ea642f89a7","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"d3c241f7-4e5d-43e7-8db1-2f49b514e50f","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":0},{"id":"873eb090-5d2e-4655-998f-7149aa55e3c1","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":0},{"id":"7d9528f7-6004-4d8d-a88f-8cc0eab052cb","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":0},{"id":"68cd96fd-0ae3-42a0-b386-cce0d1c6d29f","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"79826359-4c1d-4c76-8998-796948decde5","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":0},{"id":"b288185b-6cb3-473a-902c-fb8fd9b2d4ab","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":-1},{"id":"86bd0d3b-a130-4d53-9a1a-08bcf8d380a5","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"67970cfb-8d1f-44ff-828b-8104b6a45fc0","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":0},{"id":"9295ae02-e825-4481-a879-34e82dce2291","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"01ef932e-eb1a-455b-bd58-ce01bba6dd8c","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":0},{"id":"b010f5c3-9a3b-4a86-8c91-c040b389ce0d","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":1},{"id":"d35b29fb-4d6a-4341-b159-98a58879f80b","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"ca8b1e32-56b2-4a2f-ad64-5659d5d55eb0","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":1},{"id":"5486f0b0-6747-48bf-897f-d54fa042e22a","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"665892ef-adf9-4ffc-917d-908656190c91","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":1},{"id":"94272ea2-2bd6-409b-ba15-7cd0e094ec11","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"28029ba9-4fcf-4445-9d7a-a33645b0b473","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"f586e728-2de8-4380-a8c2-ddfaa8d9edff","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"1b807650-4adc-4318-8816-7a45504fdd32","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"ea28ec78-ec0b-4c97-bc65-487af8bcaf5a","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":1},{"id":"1fd5f3bf-20fd-4680-bfe8-cca4d80da446","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"905d8b74-ea91-4b1a-930b-a5c059db52d0","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":1},{"id":"4bf9f4eb-ca73-449f-862b-1b3216974852","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"b7d1ebdf-2e4c-4845-87f6-6d7d82c45ad4","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"49683cb9-297b-48ed-8cd7-f155fe849299","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":0},{"id":"41a16ff6-7f16-4e6f-af95-67703cf78b77","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":0},{"id":"db409803-3a0b-4253-9aa9-b02c3aa28864","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"748a5a90-7a77-4c1f-b9be-a4e146f0797c","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"2464b1b3-095a-4276-a8fa-177f474f7b8b","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":1},{"id":"3966a4a3-e5fa-4d9d-b634-09abd48927d4","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"16c1d5da-8f01-469c-bb3e-b532761130e3","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":1},{"id":"2f9af313-b486-4470-a43e-bb1b14af1b7a","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"fac475ee-40c5-414e-bff7-62e7ebb3f575","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"74d84571-153c-4724-a9a4-00b82dd4e8c7","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":0},{"id":"4d3ba77c-a4d1-48c2-b97b-2254ed6cb8de","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"2f41c157-4d02-43bf-93a1-c36f0f392a15","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"949869cb-c064-4aba-93c9-b08a235eb58a","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":1},{"id":"15251b83-21ab-451d-a1bb-0004dd7f94a6","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"2f853984-ba5c-412a-8f79-294a21a3a3eb","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"eeb88d64-4b0f-4320-9db0-5bde6c44748d","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":1},{"id":"1ad14659-bf3e-49cf-8e24-c3ce38ce4cce","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":0},{"id":"5f39e791-454b-45b4-969c-cb91cb8dabb4","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":-1},{"id":"599346a0-3ab6-407f-8769-39afdbe2c66c","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"e07d06a3-00c3-4008-aa1e-0c8dd3792e7f","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"415e885d-27f5-4b24-becf-667a2917a5a3","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":0},{"id":"66497e7b-a8e0-4566-b32c-9fa410b597ba","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":0},{"id":"032929b6-40c2-438b-97fa-8af28850c3bb","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":0},{"id":"78f7edd8-e3aa-49cf-8944-df29d5189975","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"9a593e32-a0c6-4220-83c7-9ef7f4cdbc25","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":-1},{"id":"6aa4c305-dc04-4504-b72b-1067d9b48285","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"45b7f90d-377c-4100-b733-acea0357dcc9","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"cf604ee3-8082-4b50-9100-fe6cbdcb4c08","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":0},{"id":"79ef7aee-6fd7-4c18-832c-86c38e99607e","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":1},{"id":"95eee81c-1224-46c6-9615-2def12d6ef01","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"c673adb3-a4fe-4926-bb88-44a89aa9b72d","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":0},{"id":"24b1410d-b775-4340-96ec-b95bf3edcdc9","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":0},{"id":"424d8ff4-77d7-4df4-a4b2-f48ab8b372de","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":1},{"id":"b93f5782-46dc-480c-81ef-74e9e1b88448","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"20133f7b-50cb-445d-8290-ffc387cb0407","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":1},{"id":"d3d32f86-2fa4-4cea-b620-d14740d2a875","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":1},{"id":"36463232-eecf-4821-8782-2c76205aee43","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":1},{"id":"4e70fdfc-4dd8-4aca-9f94-2e01c8e01024","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":1},{"id":"c6279c62-6100-45c7-88f4-9e9c017a5a11","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":1},{"id":"c79cdc4c-c01b-449f-bcb5-16fc5dbca8f1","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"501a9d53-78ce-42e3-b0c6-8daf2262fc25","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"95160243-ffa2-479c-9e14-6d455f48bc69","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":0},{"id":"6955379b-23d6-4377-ae46-1e031f0ce04a","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"8f242234-66b1-4c03-9a9b-df9aef2a6997","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":-1},{"id":"800c3091-02d0-4eca-a51b-3e34ff7479a1","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":0},{"id":"9fbc7f84-d210-42ed-b3da-b3156b23c2aa","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"1edb89f5-c9e4-4036-8a17-1d8849aefeb5","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":1},{"id":"678814e1-3642-4183-b335-b74516b7d3c6","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"8fdef0fe-8c0a-4f9b-a49f-ff831751afb3","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":1},{"id":"555a25e5-78ce-4625-9b9a-794ac7464037","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":0},{"id":"711cba80-1506-4495-bb7a-4c7a66e05414","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"40ae65e7-c8b3-4618-9c16-aa43a6cc12f8","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":0},{"id":"f17693fc-4801-426e-be5e-b327aae2b208","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":1},{"id":"e2c21db7-c8a0-4a42-8be8-c98cf7c75743","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"73c83f8c-bd20-4378-996b-f45643e065ff","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"c75a8ce1-04e4-4e47-b5d5-a8f03a077fcc","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"6973571e-c356-4afa-95c8-a191055a6009","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"0f938f4f-6f80-4dfd-b54c-cc85eef0b2d7","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":1},{"id":"eaa11b1f-7248-4ae8-9826-559564fefcf9","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":1},{"id":"1232f5e8-553f-4762-a052-5e6d275c3abd","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":-1},{"id":"f7527460-7430-46c8-97c3-25887cea22a6","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":1},{"id":"33335199-8577-47a4-b8d7-3a597e016827","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":0},{"id":"ed626d13-b256-4878-be0a-19b2e5527aeb","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":1},{"id":"91cdee8d-0763-491f-b3d8-9f913677ebb1","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"b9051c15-8623-4266-beb8-6fad5a99d480","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":1},{"id":"b654993f-9cf0-4e36-a0e4-bfc1025b57c2","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":-1},{"id":"2f0d7c33-6f6e-45ef-9359-2ab8612b0a77","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":0},{"id":"599f98f0-6c35-4da3-bf8e-cf46c8801983","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":1},{"id":"79b1765f-dee8-41f2-893c-022694aa8196","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":1},{"id":"3c1493ff-1b09-4b0e-acd2-28f09050d82b","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":0},{"id":"a37a5c34-060e-4885-9e04-b49477990b3e","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":1},{"id":"41abe323-d5e8-46d7-bda1-56c59dcb8423","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":1},{"id":"b14b8999-a51c-4e59-a0cc-478bce51f5b1","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":0},{"id":"ac172121-d74d-4940-ae45-dbeda1736f50","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"21b257bc-a608-4492-9655-ea051a31981f","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":1},{"id":"6fcb2249-491c-4e05-a131-e8687726c251","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":1},{"id":"da5ec411-c6f3-46eb-8353-6321b4907123","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":1},{"id":"40d75b4a-d35a-4af7-8590-4bd9bc35e299","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"5c891c11-faaa-4325-8fd5-75c6f8a4894b","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"7eab1014-e107-4ceb-b510-14d4ae9745bb","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":1},{"id":"8118c3e8-3a79-4f26-8d08-130d22cf70d5","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"a66a6aa8-bf1e-4b9b-a9b2-d8064feded61","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":1},{"id":"7d08726a-d141-412d-8852-1129d3de2249","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"d5a60bcb-73a8-4ed7-831d-07d788f66e7b","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"a7deded1-7050-48cb-8d4f-7c849568cf01","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"8a7107ad-6780-42d0-b965-9dfad8455f75","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":-1},{"id":"1c519dce-1106-43be-915b-6e5e1fbf38a0","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"62866517-7aa7-4623-a328-9990d43c2ce4","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":0},{"id":"7dd9c3b0-2295-4b20-9bb8-408783263ff0","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"a4f4d4d7-4a47-46d3-86ad-601e37edc06e","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":1},{"id":"98a3484b-c69a-4be4-9199-756102b1805a","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":1},{"id":"53087ccf-c664-432d-87af-285178560a4a","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":1},{"id":"a74b291a-398d-40dc-8352-368f70d5f140","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"26da0dc1-dcc1-4c04-be91-dc9a7522f954","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"de646bdb-fd7b-4aad-afc9-a49b288c51cc","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":1},{"id":"37bb84ed-a510-49bd-bf98-50335f4a6ae7","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":0},{"id":"9eea0ef0-2d64-4d4d-acdb-e0f9eb66d905","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":1},{"id":"825bac6d-64a6-4b2c-a495-252a5dc65dc0","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"da449a08-3f74-4adc-96cf-9a1ae86e7175","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"59bcabca-e1bb-4441-b1f6-717c3903805d","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":0},{"id":"c141b5fb-0dda-4d4e-8e23-40534ac2eec3","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":0},{"id":"b8ae40df-eed0-49b1-a34e-fe3b48c3dac2","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":1},{"id":"0a227d28-64c2-4cf3-a928-c8dbd0921446","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":0},{"id":"a045c0c4-d79a-4438-9ef2-3c39fbaa1e19","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"ef7c417d-58ae-4f17-a4ee-30369f42cf45","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"db491039-75d9-46d6-99a0-bdbcc8129c97","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":1},{"id":"61d90d21-c662-4d3d-9c9e-e296878f79c3","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":-1},{"id":"a6a074bd-0f6e-4ed0-a761-1c6b894592a1","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"981f06fe-b315-441c-8256-a5f32759a187","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":0},{"id":"d0c71c52-4588-49c8-8f94-00b957c73fd2","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":0},{"id":"9ece8bd1-f967-4850-9040-037a9ac2be4c","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"507d0465-9d53-4dc7-b6b2-6d1695a56803","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"c55ca8d9-f3ce-4724-9944-be8fcf96a068","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":0},{"id":"1f9073fe-572e-4677-a911-9659d8fafd8b","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"e20063f6-72d7-4db1-8618-09f24cae3577","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":0},{"id":"ac459682-428a-4fdd-a941-73d7fad6d54c","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":0},{"id":"886e5c8f-e040-4e16-b84a-a42b1303e45a","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"e120dfd7-d589-4e65-8627-9a39baa0eebb","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":1},{"id":"43c748b1-6bc7-4ced-a7bf-960cd174d2bb","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":1},{"id":"69d03b4d-59e3-4fd5-b7fa-c620ff049776","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"0bac267b-35ba-4ae2-9995-cbc779468aff","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":1}]}');
INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES
 ('f2aab238-9d79-4272-bd3e-0085f2f86a9a', 'b222aa15-715f-4752-923d-8f33ee8a1736', '215640fd-ee60-4f66-82bc-d173955b2228', NOW(), '{"id":"f2aab238-9d79-4272-bd3e-0085f2f86a9a","groupRatingItemResponses":[{"id":"41ae3323-8e28-4007-8496-a855ee289a6b","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":0},{"id":"1bc4cd7f-986c-4fee-8885-876edc9e0750","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"5c618291-1c36-41dc-b1c8-46ad2c6a87e3","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":1},{"id":"0845eb43-1a19-415a-a72e-76c127f2c941","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"fab41395-2e13-4744-b22a-9b55d17f269b","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":-1},{"id":"60340f2f-130f-4451-8c35-177b6cb4c224","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"e2c75623-cac2-4141-a11f-b43dab687924","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":-1},{"id":"082e27d8-6bad-47b1-ae17-fa70a7e5ffe0","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"19fa9f2f-33da-4217-a800-c22c739f014c","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"5a577cab-898a-443e-92d7-207f02b3cf36","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"1f9dc2a9-8717-4136-804a-f9e2bacfad38","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":1},{"id":"95177f4f-a49d-4ec3-b53f-d7c143f16c39","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":0},{"id":"ecb0c7b8-00a3-454c-a207-5b9942812c46","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":1},{"id":"93aa2862-7ccd-424d-ab61-dd94f3bd5c83","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"9ba02f14-99c1-4e47-b222-2c84e625f510","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"25771d8d-ebac-4482-853e-ae18eee71361","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":0},{"id":"d85241b5-a9a0-4187-a6cb-3828f621e079","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":1},{"id":"2869ab51-cae0-4797-a397-315538924df6","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"0d7eb0f0-462c-4b8c-b090-87eab11b6d9e","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"d46edf60-3199-448b-b6d5-9ee950c17d94","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":1},{"id":"5e11d072-24de-4abd-bb25-90c427e4a6f7","groupRatingItemDefinitionId":"f47f0087-2d3e-42fe-bbbb-0ca080196b4e","groupRatingItemDefinitionName":"Accountability","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":0},{"id":"237ff9eb-b5ce-4017-9aea-273ccd439f66","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":0},{"id":"9213e99f-d73e-49a2-867d-fa0cd1764ccf","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"28c28546-ea2a-47f2-9165-756684d17aaa","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":1},{"id":"f2b50608-e479-4f8b-a77a-704e0c8e19bd","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":0},{"id":"c3a3c77f-3cb6-42ae-9d4e-733ba7eb5b27","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":1},{"id":"6377d252-aa25-437d-923b-0562a0bc42a9","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"7c2e856e-7122-4d9c-9a41-e8f97dd7e263","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":0},{"id":"027e728f-73b9-4c2d-b8a6-6f49ceadf853","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"4b3ff844-5d16-4123-89a1-15eb2724b327","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"4a1cc2dd-4831-4e0e-94cf-12a8a034c2df","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"f0eb712e-9470-42f5-bc08-a4899e0454ce","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"f439e59d-e18c-4a50-a10a-3cdf47946b15","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":1},{"id":"f8bfbbe7-54fb-4e2f-9e87-fd6cb9abf319","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":0},{"id":"5866e792-b16d-4bed-96ed-3b96dae6a626","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"96d828d3-3929-4972-8fc8-0e3b1fb07be1","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"05c4ed5b-9b59-41e0-86f6-f1569dd42c6e","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"e0da97d0-17b4-4f85-af8c-84126e0a865b","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"8939fad4-8d2e-4b26-8f8c-3007dfc05ce3","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"7e1f0817-92c7-4bd9-9cc4-7d901a3ad955","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":1},{"id":"f95236bc-2b85-4d32-ac87-7437e2903fe2","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":1},{"id":"a0547146-0d79-4081-9e8f-3cc6fdf3366d","groupRatingItemDefinitionId":"a6548403-e8db-40bd-9076-ecc3412c99ce","groupRatingItemDefinitionName":"Competence","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"b3850250-0665-4dae-b034-a20f95e2ba75","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"afb1a0bb-e4f9-4a99-bcec-72b21f29f297","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":1},{"id":"637481e1-6564-4518-aafb-d60c83d073bc","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"27c818f5-0c9b-4672-b1d9-3c5db6a48f42","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":0},{"id":"d6b26cc2-1afc-4775-9699-7e802ba1d965","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":0},{"id":"9063400b-ac3f-4144-a5e1-3b8f23c1e4d4","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":1},{"id":"b3938ba5-1697-43dd-b12e-48df6bf40f0e","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":0},{"id":"eeadb548-bc33-47f6-bb78-f40fcbadf00a","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":-1},{"id":"5b3e9ef2-a633-4b8a-9817-1b1d445cc63a","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":-1},{"id":"08fc37d0-e479-4a0f-bb4f-a86fd93be4ec","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":0},{"id":"91650aec-f2ff-42f6-ae89-751b4c3eb664","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"4010ec49-3250-4104-8e47-56558ed54f95","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":1},{"id":"11734bf3-f076-40de-94df-cf4f75fc06cb","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":1},{"id":"e37d9133-e11a-410e-83be-090fbc2a71e9","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"df3c72c8-77d4-428b-a3c4-87991d5d743e","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"91a22098-6caa-4c62-bf7c-37166d35ac44","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":0},{"id":"44d20c33-a3a1-420f-8846-b1398d08171d","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"5f2b6884-4f07-4f78-a6f2-9d98a45430d3","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"51db3b87-56ac-4052-a0e1-10c077fa1ac6","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":1},{"id":"86987ecc-afb4-4225-b411-aaac7f0c7ee0","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"9fff7758-9c27-4f59-99b1-ddbbf73585cc","groupRatingItemDefinitionId":"34f4d372-fa72-4309-b7f0-b3531851511f","groupRatingItemDefinitionName":"Courage","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":0},{"id":"e3eddc72-cb8e-4460-acaa-db5c80724892","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":1},{"id":"f161787f-d3f7-478b-8a01-eb10adf422f2","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":-1},{"id":"1e6bb066-266e-4f1b-b0f8-9cf501fc2e98","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":0},{"id":"f478d979-dc0d-44ed-ada2-cffb134f79d1","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"26dc4602-b9a2-4b44-92de-a7bdbeb5409d","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":0},{"id":"ae5079a6-7d44-4a86-b7a2-5fbc2c4fa2d5","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":-1},{"id":"3acd998c-9cfe-4813-ac48-f33a1c2ac0df","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":0},{"id":"5b07e4b0-ff04-40d1-9a82-1a1fd1f92717","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":-1},{"id":"4197fa51-bbd8-4c8e-abaa-41b76afa8c48","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":0},{"id":"4301e095-79c8-4af8-9c2f-500d96cb9ab5","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"b721a827-b316-4535-9ed0-a466c2169e31","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":1},{"id":"54c2e7b6-21b2-4715-9ade-8d7a7c1887e3","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"9aefc185-0597-472e-835d-901c08c47804","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"9d457f83-c218-48f8-9fad-1e4c81d0a0c3","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"95257aac-01ba-4344-bd29-5534b88b6367","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"26ff22f8-bd6c-4216-9470-3812fad96be4","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":1},{"id":"18c61424-d4b7-447b-8491-a23e443a5bcc","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"eaa4f911-fe64-486f-9903-12807fe7e3d3","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":0},{"id":"2c479313-ae80-47fe-b7f2-5e42fe4eed95","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":0},{"id":"474a77a0-dba5-4e66-a8dd-3853211cb2b3","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"a6a372e2-6c57-46ed-9853-0461eb276b50","groupRatingItemDefinitionId":"dcfb54c9-a170-4027-b0c0-963ff624eca8","groupRatingItemDefinitionName":"Fairness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"e09ea28c-8512-415c-81f7-21f7f03c603c","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"a5c2ebe0-5661-42e9-877c-8f008d4d2a4e","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"e5ab78b3-f326-47c3-a729-792b4e6b51ab","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":1},{"id":"d18b97c2-b670-406e-81fc-5ea5475b1e4d","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"73f7ebbe-bf4f-416a-848e-685b39816b06","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":1},{"id":"91c3819e-48dd-4f8b-8641-6589502251df","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":1},{"id":"67c6dc30-41de-4f67-ae46-36d5028ba969","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":1},{"id":"3c93ebb9-31c6-4398-b473-249a813e0ab7","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"4ee8ddf1-d9c9-45c9-b3e8-c4f3b8df9096","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":0},{"id":"41380bab-90cd-48b2-ad2f-7d0f34291720","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"f618e20a-d03b-4879-bdf9-4f020da6de2c","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"eae656c4-bb06-4099-9ac1-00233ea269ce","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"f1399699-7ac4-4192-93b0-14ae1e0bff6f","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"f2306532-c366-4dcc-ac2c-916b958f9be3","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"e30f4f26-01d3-4515-9d30-38812395d787","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"8564bb06-e17d-4ad8-94fd-b14a69fcccf3","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":1},{"id":"4c88f885-38ba-4ad9-9fe8-3d06230f86fa","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":0},{"id":"98905794-a142-4968-967e-6398494e9cef","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":0},{"id":"8726a612-b891-4f31-b51d-f2ac94f38831","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":-1},{"id":"27e60801-14a6-4c90-9e01-c933d966c9c1","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":1},{"id":"93002cca-ccb8-4cd0-ad47-04a2a480d5b4","groupRatingItemDefinitionId":"f3020302-7aed-458b-96a3-02ec33f126ca","groupRatingItemDefinitionName":"Integrity","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"73f0051c-acce-42f2-a3c2-d816337a7487","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"b89a862a-48e2-4a08-83f8-8dadb3b6245c","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"bbf20fab-4935-40cf-91a0-ac7273d79f5f","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"89f81030-66e2-46ce-b1d6-935e0035c59e","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"e2c3c522-e8b7-4482-a8b0-fb96921c42cf","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":1},{"id":"86b85ace-2513-41b8-b1d5-8be7df360c50","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":1},{"id":"37646894-4b0f-4242-bb95-c974265f0da7","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":1},{"id":"6df607f8-d81e-41fe-8b69-a6d6074a3e8c","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":-1},{"id":"5e6ba20c-32fb-4be7-b296-c09902296eea","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"ed751dc4-57aa-4b36-ac92-53a86d70fee6","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":0},{"id":"b95d0d90-f9d9-4bf0-a504-7268126ab5f0","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"32de1110-cf57-4df4-a000-cc35a6ce141a","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":1},{"id":"9f6da192-ff0d-4654-8afe-a88f878d9f6c","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"275638c3-e5e2-4a56-840a-d179923b7c97","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":-1},{"id":"7f17c9f5-3878-4b20-a65a-4b9a09e7cd21","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":1},{"id":"35c7a3c4-8440-4e69-bf43-3fce73769f56","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":1},{"id":"417a8f79-4828-4091-8a2a-0b143d5f7698","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":0},{"id":"6f823fac-b6a8-452c-982f-4bf03cc2b8ca","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":0},{"id":"1650ba75-96c6-4dc9-90e0-9cfc4c2304b7","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":1},{"id":"9f51b9ca-c005-4b69-bddb-c40d5ce9d5d0","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"4dad429b-0895-436b-9e2e-19fd642f6738","groupRatingItemDefinitionId":"fab5d7a2-231f-44af-82e8-cbc045c6a77c","groupRatingItemDefinitionName":"Openness","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"1336f836-8b37-40a7-83b2-15fe8fbfae39","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":0},{"id":"11292e52-5d3d-4a81-84d9-39c43c7d8806","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":1},{"id":"995e6eef-c51f-40c0-b5c2-17e590f969a1","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":1},{"id":"06f379c6-a964-41e1-b07d-9658cf3bc3d1","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":-1},{"id":"9d139670-d1a0-4469-8402-3d43271a6499","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":1},{"id":"f2114f3a-85a8-4b40-9ff0-848e4b82de0a","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":0},{"id":"0c086c8d-2417-461c-950b-6cc4c661f86a","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":1},{"id":"8f03b08e-7d16-4b64-8b32-d2d37f9cf23d","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"291e0a80-75de-4c0e-8265-f9b3c447057e","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":0},{"id":"febb1add-8c90-4949-a80f-3a700666b805","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":1},{"id":"03473161-f1c0-4e6c-a8a7-31a72f63ab64","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"d9adcf23-951a-4be4-aac2-9692dd1cad42","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"eae04beb-70bf-416e-bb74-88df94dede87","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"cd13bc95-cc5b-435e-bee9-341636fb62c3","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":1},{"id":"40cfe72c-c1a2-42c7-bdcd-e72ce6bbe25c","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":0},{"id":"c383108d-a29f-4b5d-8a7c-740be8b2280c","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":0},{"id":"e50fcae2-4074-48b8-9c0b-380b886ac307","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"bc1f56d9-1f7b-4e29-842f-0956408fb687","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"b09903dd-8355-43bd-8dc6-9706555040b2","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":0},{"id":"c8037cd0-780b-46c1-b97e-9b0fa94f21d6","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":1},{"id":"13c4b191-f608-4b07-aad7-da6964704ac4","groupRatingItemDefinitionId":"f609873a-30b4-43af-9514-ba9a54919250","groupRatingItemDefinitionName":"Positive Attitude","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":1},{"id":"c19bb396-3733-4ce0-8180-935b00805683","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":-1},{"id":"55c68600-d1df-45e6-8a14-fc90d41e5087","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"4f679fd1-6812-4fef-940f-af8daa904332","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":-1},{"id":"3ada0018-7a90-4bb9-8fcf-d5355833347e","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":0},{"id":"8258d530-18da-466a-ac6d-25bb354a8957","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":1},{"id":"520c6186-e0eb-4964-98fd-16f0c78c4f21","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":0},{"id":"16737d18-a59f-4523-8e03-79f9c1a4bbbc","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":-1},{"id":"95de2abb-e431-45eb-ba3b-5159abf30b20","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":-1},{"id":"b98925ad-bafd-4395-a0f0-8678b82c1ff2","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"148639e2-36ac-4195-9184-4385e1d4ea7a","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":1},{"id":"43d1d969-1745-407d-8109-fe740693c1c7","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"ce4f85be-450a-4491-93af-180432f0c949","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"b7f64852-e490-4e9e-8648-c5cc7509a1b8","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":0},{"id":"3271faa4-bf3a-4838-b2ba-391704f42d07","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":1},{"id":"1cf420cb-093c-438a-846f-293f019b6c7c","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"549b2b8e-8c36-4a50-bbc5-0f66f573fed1","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":1},{"id":"9013abd1-9882-4677-bb53-f42bca57505d","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"0adcfeab-8890-46ff-9cb2-e98f7f60573c","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"7e80974e-2d26-406f-89f7-b2115eb1b393","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":1},{"id":"8c12908d-4dc1-46df-b2f8-beaf51ea17c1","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"43031c46-f6c1-420c-9717-4cced59b11c7","groupRatingItemDefinitionId":"69f9e11a-eaf8-498c-a959-c7b312e45598","groupRatingItemDefinitionName":"Teamwork","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":1},{"id":"cd039598-ddb4-486d-a6a1-988f02f2c32b","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":0},{"id":"e1c1dd1c-58b3-4423-bd03-720f1a9bf9bc","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"a2e61cb7-70e6-4fad-89e7-203ea132eee3","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":1},{"id":"9ef820e7-c7c1-4d27-bfdd-c3945b0f148a","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":0},{"id":"2dde8675-1629-4ecf-b352-89f2826a8c66","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":0},{"id":"25351496-5537-4be1-b761-ac2218499dd2","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":1},{"id":"0b1c0f29-7d19-4375-9cd6-00a6aebd9464","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":-1},{"id":"94bc95f8-ab93-4a75-b5b0-9429026828ab","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":-1},{"id":"47565eb6-be6c-4cd4-8a21-63954aee86c7","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":1},{"id":"35d532fe-8374-4794-bdcb-6df2e3349463","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"a3a27aa4-8a62-401a-aa60-5f783ab57521","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":0},{"id":"8216638c-ffac-470b-a505-5bd3682ab3d0","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":0},{"id":"a23c1e19-cc00-4769-9e60-6ef617d907ae","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":0},{"id":"c9c4a1ae-c18e-4b7e-9f30-5b4b9c403c48","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":1},{"id":"7a760920-0c99-4aaa-b1ed-478df726e051","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":-1},{"id":"fe1fc3f5-8326-49de-9ae8-4747851b73c0","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":1},{"id":"d26e2ee5-1e46-4c58-a906-7106a9e4f043","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":-1},{"id":"c45bbf86-4c88-4b5b-8ab7-eff2e014cd95","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":1},{"id":"e08ca464-3a46-4988-af49-8dd7a3f40346","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":0},{"id":"5fcc3215-7508-4a78-bea3-991d2ed36760","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":0},{"id":"952ce29b-afae-4ab0-813f-d3104803e3b4","groupRatingItemDefinitionId":"1db206bc-60be-4bcf-af83-b907cb9ac534","groupRatingItemDefinitionName":"Making a difference","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":-1},{"id":"3d4e3d84-8832-4a6e-81d4-b70e91fdf25a","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"ec6994f0-4fd5-4bbc-a56e-da4648e6b1d7","groupMemberDefinitionName":"CTO ELT","rating":1},{"id":"3f95df13-2494-4821-b727-30d0c1ffa026","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7156e85c-13f0-4f87-bcbd-4f0bad470c31","groupMemberDefinitionName":"Peter","rating":0},{"id":"7dbe9711-d45f-49c1-9846-97b22a43f7aa","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"2facaf21-3969-4840-860b-632ab3bc729e","groupMemberDefinitionName":"Adriaan","rating":0},{"id":"c343473c-ea0b-45ca-9b44-693dd9333da1","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"babb428e-a6e2-4a06-9258-f776a9d6a818","groupMemberDefinitionName":"Alapan","rating":1},{"id":"57e8d8bb-0901-4529-8096-539b17cf2fd1","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"8bc452eb-5df7-4d8d-8d4d-de8001b02e7a","groupMemberDefinitionName":"Dan","rating":0},{"id":"9bd82e41-d4f6-475f-86e3-790fa474a291","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"b3388169-2369-458e-8fad-66e791e897a4","groupMemberDefinitionName":"Daryl","rating":0},{"id":"494bfc97-c884-4fb6-85f6-39f4dee5db36","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4c112f21-c002-43b9-827f-7414dd334937","groupMemberDefinitionName":"David","rating":1},{"id":"55394d98-267b-491e-b979-5e79e53505df","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e75c1e38-0bb2-4dc6-914b-b53b908b5059","groupMemberDefinitionName":"Francois","rating":1},{"id":"918bb17b-99f9-4217-8269-73eb445f0255","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"e849883a-ef72-4902-9246-5d3b5b0df9d4","groupMemberDefinitionName":"James","rating":0},{"id":"1d27f5c4-e363-4d7f-842b-0f9737f6a0bd","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"f22c2dd9-47c8-4071-886c-7b0164597ef5","groupMemberDefinitionName":"Kersh","rating":-1},{"id":"568ed623-0ca9-4f6f-b235-577eae35bd4e","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"1395d417-c201-4f87-b2ed-5dc41bd68821","groupMemberDefinitionName":"Kevin","rating":-1},{"id":"6d267e94-81d3-4787-adad-6fa2c0dca133","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"c9075011-d31e-4104-9f0f-288011187b24","groupMemberDefinitionName":"Linde-Marie","rating":-1},{"id":"51c5043c-0ed1-496d-b8d2-2c1b4c1d271e","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"3b1e87b6-c5c9-4cff-bbbd-5e1fbe32bfe5","groupMemberDefinitionName":"Manoj","rating":-1},{"id":"a3c1bfcd-4e6f-4e21-9f4b-af0c7ae234fb","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90653250-746a-40eb-b249-24b67b43b231","groupMemberDefinitionName":"Marcus","rating":0},{"id":"c024a03a-5576-495d-a5e4-b831a360fb59","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"97d0753c-35b8-41c9-82f6-61b438ebba53","groupMemberDefinitionName":"Mercia","rating":1},{"id":"7c47dc1b-86f4-4c63-acf4-29acf58e6e44","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"4a135226-7a3d-44b6-8218-c96295fae93f","groupMemberDefinitionName":"Nicole","rating":-1},{"id":"779fb5cd-4f85-4c6f-9d17-26cd7e0bcb1b","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"90f92a27-b135-496e-821d-d13fe11a1e32","groupMemberDefinitionName":"Lawrence","rating":1},{"id":"f89d6427-5cd2-414a-8606-4ed19d100714","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"45dd128b-3b62-412b-9d9e-1a061e33fa9d","groupMemberDefinitionName":"Richard","rating":-1},{"id":"98fa0c60-80af-4132-9627-fbecc7eafac4","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"bf83691b-13ff-4b8c-bedd-cc6cba5a2e40","groupMemberDefinitionName":"Sandra","rating":1},{"id":"29d9f39b-bbee-4fba-8fbe-cbe50764818b","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"9beefe22-7b8d-432c-b19f-55ec05036703","groupMemberDefinitionName":"Tendai","rating":-1},{"id":"6da473e2-1444-483a-a622-886a13d62324","groupRatingItemDefinitionId":"9482b46c-c207-4df7-8cbc-0bd5c1942902","groupRatingItemDefinitionName":"Trust","groupRatingItemDefinitionRatingType":2,"groupMemberDefinitionId":"7342cb72-2e3d-49dc-9e64-7edeab4867bc","groupMemberDefinitionName":"Debbie","rating":0}]}');


