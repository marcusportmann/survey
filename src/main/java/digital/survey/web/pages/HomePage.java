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

package digital.survey.web.pages;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyInstance;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.AnonymousOnlyWebPage;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.markup.html.link.Link;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>HomePage</code> class implements the "Home"
 * page for the web application.
 *
 * @author Marcus Portmann
 */
@AnonymousOnlyWebPage
public class HomePage extends TemplateWebPage
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Survey Service.
   */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>HomePage</code>.
   */
  public HomePage()
  {
    super("Home");

    // The "surveyResultLink" used to view the survey result
    Link<Void> surveyResultLink = new Link<Void>("surveyResultLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick()
      {
        try
        {
          SurveyInstance surveyInstance = surveyService.getSurveyInstance(UUID.fromString(
              "b222aa15-715f-4752-923d-8f33ee8a1736"));

          setResponsePage(new ViewSurveyResultPage(getPageReference(), surveyInstance.getId(),
              surveyInstance.getName()));
        }
        catch (Throwable e)
        {
          throw new WebApplicationException("Failed to view the survey result", e);
        }
      }
    };
    surveyResultLink.setVisible(false);
    add(surveyResultLink);
  }
}
