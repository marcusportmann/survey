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

package digital.survey;

//~--- non-JDK imports --------------------------------------------------------

import org.apache.commons.cli.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wildfly.swarm.Swarm;
import org.wildfly.swarm.config.undertow.FilterConfiguration;
import org.wildfly.swarm.datasources.DatasourcesFraction;
import org.wildfly.swarm.undertow.UndertowFraction;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>Survey</code> class initialises the WildFly Swarm container.
 *
 * <xa-datasource jndi-name="java:jboss/datasources/SurveyDS" pool-name="SurveyDS"  enabled="true" use-java-context="true">
 *   <xa-datasource-property name="URL">jdbc:h2:mem:survey;MVCC=true;MODE=DB2;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</xa-datasource-property>
 *   <security>
 *     <user-name>sa</user-name>
 *     <password>sa</password>
 *   </security>
 *   <driver>h2</driver>
 * </xa-datasource>
 *
 * @author Marcus Portmann
 */
public class Survey
{
  /* Logger */
  private static Logger logger = LoggerFactory.getLogger(Survey.class);
  private static final String GZIP_FILTER_KEY = "gzip";

  /**
   * Main.
   *
   * @param args the commandline arguments
   */
  public static void main(String... args)
  {
    try
    {
      Options options = new Options();

      Option portOption = new Option("p", "port", true, "the HTTP port");
      portOption.setRequired(false);
      options.addOption(portOption);

//      Option dbTypeOption = new Option("t", "dbType", true,
//        "the database type");
//      dbTypeOption.setRequired(true);
//      options.addOption(dbTypeOption);

      Option dbConnectionUrlOption = new Option("c", "dbConnectionUrl", true,
          "the database connection URL");
      dbConnectionUrlOption.setRequired(true);
      options.addOption(dbConnectionUrlOption);

      Option dbUsernameOption = new Option("u", "dbUsername", true,
          "the username for the database user");
      dbUsernameOption.setRequired(true);
      options.addOption(dbUsernameOption);

      Option dbPasswordOption = new Option("p", "dbPassword", true,
          "the password for the database user");
      dbPasswordOption.setRequired(true);
      options.addOption(dbPasswordOption);

      CommandLineParser parser = new DefaultParser();
      HelpFormatter formatter = new HelpFormatter();
      CommandLine commandLine;

      try
      {
        commandLine = parser.parse(options, args);
      }
      catch (ParseException e)
      {
        System.out.println(e.getMessage());
        formatter.printHelp("survey-swarm", options);

        System.exit(1);

        return;
      }

      // Set the WildFly Swarm configuration properties
      if (commandLine.hasOption(portOption.getOpt()))
      {
        try
        {
          int port = Integer.parseInt(commandLine.getOptionValue(portOption.getOpt()));

          System.setProperty("swarm.http.port", String.valueOf(port));
        }
        catch (Throwable e)
        {
          System.out.println("Invalid port number");

          System.exit(1);

          return;
        }
      }

      System.setProperty("swarm.context.path", "/");

      // Instantiate the container
      Swarm swarm = new Swarm();

      // Initialise the application data source
      swarm.fraction(new DatasourcesFraction().jdbcDriver("org.postgresql",
          (d) ->
          {
            d.driverClassName("org.postgresql.Driver");
            d.xaDatasourceClass("org.postgresql.xa.PGXADataSource");
            d.driverModuleName("org.postgresql");
          }
          ).dataSource("SurveyDS",
              (ds) ->
          {
            ds.driverName("org.postgresql");
            ds.connectionUrl(commandLine.getOptionValue("dbConnectionUrl"));
            ds.userName(commandLine.getOptionValue("dbUsername"));
            ds.password(commandLine.getOptionValue("dbPassword"));
            ds.jndiName("java:jboss/datasources/SurveyDS");
            ds.useJavaContext(true);
            ds.trackStatements("true");
            ds.tracking(true);
          }
          ));

      // Enable gzip compression
      UndertowFraction undertowFraction = UndertowFraction.createDefaultFraction();

      undertowFraction.filterConfiguration(new FilterConfiguration().gzip(GZIP_FILTER_KEY))
          .subresources().server("default-server").subresources().host("default-host").filterRef(
          GZIP_FILTER_KEY, f -> f.predicate(
          "exists('%{o,Content-Type}') and regex(pattern='(?:application/javascript|text/css|text/html|text/xml|application/json)(;.*)?', value=%{o,Content-Type}, full-match=true)"));

      swarm.fraction(undertowFraction);

      // Start the container
      swarm.start();

      // Create the default deployment
      swarm.createDefaultDeployment();

      // Deploy the application
      swarm.deploy();
    }
    catch (Throwable e)
    {
      logger.error("Failed to initialise the Survey application", e);
    }
  }
}
