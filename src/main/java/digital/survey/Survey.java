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
import org.wildfly.swarm.datasources.DatasourcesFraction;

/**
 * The <code>SurveyMain</code> class initialises the WildFly Swarm container.
 *
 * @author Marcus Portmann
 */
public class Survey
{
  /* Logger */
  private static Logger logger = LoggerFactory.getLogger(Survey.class);

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

      swarm.fraction(new DatasourcesFraction()
//        .jdbcDriver("h2", (d) -> {
//          d.driverDatasourceClassName("org.h2.Driver");
//          d.xaDatasourceClass("org.h2.jdbcx.JdbcDataSource");
//          d.driverModuleName("com.h2database.h2");
//        })
        .dataSource("SurveyDS", (ds) -> {
          ds.driverName("h2");
          ds.connectionUrl("jdbc:h2:mem:surveydb;MVCC=true;MODE=DB2;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE");
          ds.userName("sa");
          ds.password("sa");
          ds.jndiName("java:jboss/datasources/SurveyDS");
          ds.useJavaContext(true);
          ds.trackStatements("true");
          ds.tracking(true);
        }));

//      swarm.fraction(new DatasourcesFraction().dataSource("SurveyDS",
//              (ds) ->
//          {
//            ds.jndiName("java:jboss/datasources/SurveyDS");
//            ds.useJavaContext(true);
//            ds.trackStatements("true");
//            ds.tracking(true);
//            ds.driverName("h2");
//            ds.connectionUrl(
//                "jdbc:h2:mem:surveydb;MVCC=true;MODE=DB2;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE");
//            ds.userName("sa");
//            ds.password("sa");
//          }
//          ));

      // Start the container
      swarm.start();


      //swarm.deploy()

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
