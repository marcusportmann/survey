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

import digital.survey.web.pages.DashboardPage;
import digital.survey.web.pages.HomePage;
import digital.survey.web.pages.SurveyAudienceAdministrationPage;
import digital.survey.web.pages.SurveyDefinitionAdministrationPage;
import guru.mmp.application.web.pages.WebPage;
import guru.mmp.application.web.template.TemplateWebApplication;
import guru.mmp.application.web.template.navigation.NavigationGroup;
import guru.mmp.application.web.template.navigation.NavigationLink;
import org.apache.wicket.Page;
import org.apache.wicket.request.resource.CssResourceReference;
import org.springframework.boot.SpringApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * The <code>SurveyApplication</code> provides the implementation of the Wicket Web
 * Application class for the web application.
 *
 * @author Marcus Portmann
 */
@Component("webApplication")
@ComponentScan(basePackages = { "digital.survey" }, lazyInit = true)
public class SurveyApplication extends TemplateWebApplication
{
  /**
   * The "Survey.CompleteSurvey.ResponseUrl" configuration key.
   */
  public static final String COMPLETE_SURVEY_RESPONSE_URL_CONFIGURATION_KEY =
      "Survey.CompleteSurvey.ResponseUrl";

  /**
   * The "Survey.Mail.FromAddress" configuration key.
   */
  public static final String MAIL_FROM_ADDRESS_CONFIGURATION_KEY = "Survey.Mail.FromAddress";

  /**
   * The "Survey.Mail.Host" configuration key.
   */
  public static final String MAIL_HOST_CONFIGURATION_KEY = "Survey.Mail.Host";

  /**
   * The "Survey.Mail.Username" configuration key.
   */
  public static final String MAIL_USERNAME_CONFIGURATION_KEY = "Survey.Mail.Username";

  /**
   * The "Survey.Mail.Password" configuration key.
   */
  public static final String MAIL_PASSWORD_CONFIGURATION_KEY = "Survey.Mail.Password";

  /**
   * The "Survey.Mail.Password" configuration key.
   */
  public static final String MAXIMUM_SURVEY_REQUEST_SEND_ATTEMPTS_CONFIGURATION_KEY =
      "Survey.BackgroundSurveyRequestSender.MaximumSendAttempts";

  /**
   * The "Survey.Mail.IsSecure" configuration key.
   */
  public static final String MAIL_IS_SECURE_CONFIGURATION_KEY = "Survey.Mail.IsSecure";

  /**
   * The default "Survey.CompleteSurvey.ResponseUrl" configuration value.
   */
  public static final String DEFAULT_COMPLETE_SURVEY_RESPONSE_URL =
      "http://localhost:8080/survey/wicket/bookmarkable/digital.survey.web.pages.CompleteSurveyPage";

  /**
   * Constructs a new <code>SurveyApplication</code>.
   */
  public SurveyApplication() {}

  /**
   * The main method.
   *
   * @param args the command-line arguments
   */
  public static void main(String[] args)
  {
    SpringApplication.run(SurveyApplication.class, args);
  }

  /**
   * Returns the CSS resource reference for the CSS resource that contains the application styles.
   *
   * @return the CSS resource reference for the CSS resource that contains the application styles
   */
  @Override
  public CssResourceReference getApplicationCssResourceReference()
  {
    return new CssResourceReference(SurveyApplication.class, "resources/css/application.css");
  }

  /**
   * Returns the user-friendly name that should be displayed for the application.
   *
   * @return the user-friendly name that should be displayed for the application
   */
  @Override
  public String getDisplayName()
  {
    return "Survey";
  }

  /**
   * Returns the home page for the application.
   *
   * @return the home page for the application
   */
  public Class<? extends Page> getHomePage()
  {
    return HomePage.class;
  }

  /**
   * Returns the page that users will be redirected to once they have logged into the application.
   *
   * @return the page that users will be redirected to once they have logged into the application.
   */
  public Class<? extends WebPage> getSecureHomePage()
  {
    return DashboardPage.class;
  }

  /**
   * Initialise the application.
   */
  @Override
  protected void init()
  {
    super.init();

    /*
     * Disable rendering of wicket tags e.g. wicket:panel even in debug mode.
     *
     * This is done to ensure that things like the Bootstrap collapse component work correctly.
     */
    getMarkupSettings().setStripWicketTags(true);
  }

  /**
   * Setup the navigation hierarchy for the application.
   *
   * @param root the root of the navigation hierarchy
   */
  @Override
  protected void initNavigation(NavigationGroup root)
  {
    root.addItem(new NavigationLink("Home", "fa fa-home", HomePage.class));
    root.addItem(new NavigationLink("Dashboard", "fa fa-home", DashboardPage.class));
    root.addItem(new NavigationLink("Audiences", "fa fa-users",
        SurveyAudienceAdministrationPage.class));
    root.addItem(new NavigationLink("Surveys", "fa fa-wpforms",
        SurveyDefinitionAdministrationPage.class));

    super.initNavigation(root);
  }


  /**
   * Returns the paths to the resources on the classpath that contain the SQL statements used to
   * initialise the in-memory application database.
   */
  @Override
  protected List<String> getInMemoryDatabaseInitResources()
  {
    List<String> resources = super.getInMemoryDatabaseInitResources();

    resources.add("digital/survey/persistence/SurveyH2.sql");

    return resources;
  }

  /**
   * Returns the names of the packages to scan for JPA classes.
   *
   * @return the names of the packages to scan for JPA classes
   */
  @Override
  protected List<String> getJpaPackagesToScan()
  {
    List<String> packagesToScan = super.getJpaPackagesToScan();

    packagesToScan.add("digital.survey");

    return packagesToScan;
  }
}
