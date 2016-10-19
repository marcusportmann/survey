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

package guru.mmp.survey.web;

import guru.mmp.application.web.pages.WebPage;
import guru.mmp.application.web.template.TemplateWebApplication;
import guru.mmp.application.web.template.navigation.NavigationGroup;
import guru.mmp.application.web.template.navigation.NavigationLink;
import guru.mmp.survey.web.pages.DashboardPage;
import guru.mmp.survey.web.pages.HomePage;
import guru.mmp.survey.web.pages.CompleteSurveyPage;
import guru.mmp.survey.web.pages.SurveyAudienceAdministrationPage;
import org.apache.wicket.Page;
import org.apache.wicket.request.resource.CssResourceReference;

/**
 * The <code>SurveyApplication</code> provides the implementation of the Wicket Web
 * Application class for the web application.
 *
 * @author Marcus Portmann
 */
public class SurveyApplication
  extends TemplateWebApplication
{
  /**
   * Constructs a new <code>SurveyApplication</code>.
   */
  public SurveyApplication()
  {
    super("Survey");
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
   * Setup the navigation hierarchy for the application.
   *
   * @param root the root of the navigation hierarchy
   */
  @Override
  protected void initNavigation(NavigationGroup root)
  {
    super.initNavigation(root);
  
    root.addItem(new NavigationLink("Home", "fa fa-home", HomePage.class));
    root.addItem(new NavigationLink("Dashboard", "fa fa-home", DashboardPage.class));
    root.addItem(new NavigationLink("Audiences", "fa fa-users", SurveyAudienceAdministrationPage.class));
  }
}

