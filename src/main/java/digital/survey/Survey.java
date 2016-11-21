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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wildfly.swarm.Swarm;
import org.wildfly.swarm.config.undertow.FilterConfiguration;
import org.wildfly.swarm.datasources.DatasourcesFraction;
import org.wildfly.swarm.undertow.UndertowFraction;

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
      // Instantiate the container
      Swarm swarm = new Swarm();

      // Initialise the application data source
      swarm.fraction(new DatasourcesFraction().dataSource("SurveyDS",
          (ds) ->
          {
            ds.driverName("h2");
            ds.connectionUrl(
                "jdbc:h2:mem:survey;MVCC=true;MODE=DB2;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE");
            ds.userName("sa");
            ds.password("sa");
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
