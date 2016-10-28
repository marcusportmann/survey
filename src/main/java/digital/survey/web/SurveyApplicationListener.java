/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.reporting.IReportingService;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.common.persistence.DAOUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

//~--- JDK imports ------------------------------------------------------------

import java.sql.Connection;
import java.sql.DatabaseMetaData;

import java.util.List;

import javax.inject.Inject;

import javax.naming.InitialContext;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import javax.sql.DataSource;

/**
 * The <code>SurveyApplicationListener</code> class initialises the web application.
 *
 * @author Marcus Portmann
 */
public class SurveyApplicationListener
  implements ServletContextListener
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(SurveyApplicationListener.class);

  /* Reporting Service */
  @Inject
  private IReportingService reportingService;

  /**
   * Constructs a new <code>SurveyApplicationListener</code>.
   */
  public SurveyApplicationListener() {}

  /**
   * Notification that the servlet context is about to be shut down.
   *
   * @param event the <code>ServletContextEvent</code> instance containing the event details
   */
  public void contextDestroyed(ServletContextEvent event) {}

  /**
   * Notification that the web application is ready to process requests.
   *
   * @param event the <code>ServletContextEvent</code> instance containing the event details
   */
  public void contextInitialized(ServletContextEvent event)
  {
    // Initialise the application database tables if required
    initApplicationDatabaseTables();

    // Initialise the application data
    initApplicationData();
  }

  /**
   * Initialise the application data.
   */
  private void initApplicationData()
  {
    try
    {
//      byte[] surveyReportDefinitionData = ResourceUtil.getClasspathResource(
//          "guru/mmp/survey/report/SurveyReport.jasper");
//
//      ReportDefinition surveyReportDefinition = new ReportDefinition(UUID.fromString(
//          "2a4b74e8-7f03-416f-b058-b35bb06944ef"), "Survey Report", surveyReportDefinitionData);
//
//      if (!reportingService.reportDefinitionExists(surveyReportDefinition.getId()))
//      {
//        reportingService.saveReportDefinition(surveyReportDefinition);
//        logger.info("Saved the \"Survey Report\" report definition");
//      }
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the application data", e);
    }
  }

  /**
   * Initialise the application database tables if required.
   */
  private void initApplicationDatabaseTables()
  {
    DataSource dataSource = null;

    try
    {
      dataSource = InitialContext.doLookup("java:app/jdbc/ApplicationDataSource");
    }
    catch (Throwable ignored) {}

    if (dataSource == null)
    {
      try
      {
        dataSource = InitialContext.doLookup("java:comp/env/jdbc/ApplicationDataSource");
      }
      catch (Throwable ignored) {}
    }

    if (dataSource == null)
    {
      throw new WebApplicationException("Failed to initialise the application database tables:"
          + "Failed to retrieve the application data source using the JNDI names "
          + "(java:app/jdbc/ApplicationDataSource) and (java:comp/env/jdbc/ApplicationDataSource)");
    }

    try (Connection connection = dataSource.getConnection())
    {
      DatabaseMetaData metaData = connection.getMetaData();

      logger.info("Connected to the " + metaData.getDatabaseProductName()
          + " application database with version " + metaData.getDatabaseProductVersion());

      // Determine the suffix for the SQL files containing the database DDL
      String databaseFileSuffix;

      switch (metaData.getDatabaseProductName())
      {
        case "H2":

          databaseFileSuffix = "H2";

          break;

        default:

          logger.info(
              "The application database tables will not be populated for the database type ("
              + metaData.getDatabaseProductName() + ")");

          return;
      }

      // Create and populate the database tables if required
      if (!DAOUtil.tableExists(connection, null, "SURVEY", "SURVEY_DEFINITIONS"))
      {
        logger.info("Creating and populating the application database tables");

        String resourcePath = "/guru/mmp/survey/persistence/Survey" + databaseFileSuffix + ".sql";
        int numberOfStatementsExecuted = 0;
        int numberOfFailedStatements = 0;
        List<String> sqlStatements;

        try
        {
          sqlStatements = DAOUtil.loadSQL(resourcePath);
        }
        catch (Throwable e)
        {
          throw new WebApplicationException(
              "Failed to load the SQL statements from the resource file (" + resourcePath + ")", e);
        }

        for (String sqlStatement : sqlStatements)
        {
          try
          {
            DAOUtil.executeStatement(connection, sqlStatement);

            numberOfStatementsExecuted++;
          }
          catch (Throwable e)
          {
            logger.error("Failed to execute the SQL statement: " + sqlStatement, e);

            numberOfFailedStatements++;
          }
        }

        if (numberOfStatementsExecuted != sqlStatements.size())
        {
          throw new WebApplicationException("Failed to execute " + numberOfFailedStatements
              + " SQL statement(s) in the " + "resource file (" + resourcePath + ")");
        }
      }
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the application database tables", e);
    }
  }
}
