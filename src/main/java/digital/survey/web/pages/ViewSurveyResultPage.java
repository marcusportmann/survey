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
import digital.survey.model.SurveyResult;
import digital.survey.web.SurveySecurity;
import digital.survey.web.components.SurveyResultPanel;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.PageReference;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.model.Model;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>ViewSurveyResultPage</code> class implements the "View Survey Result"
 * page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
//@WebPageSecurity({ SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION,
//    SurveySecurity.FUNCTION_CODE_VIEW_SURVEY_RESPONSE })
public class ViewSurveyResultPage extends TemplateWebPage
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Survey Service.
   */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>ViewSurveyResultPage</code>.
   *
   * @param previousPage       the previous page
   * @param surveyInstanceId   the Universally Unique Identifier (UUID) used to identify the survey
   *                           instance the survey result is associated with
   * @param surveyInstanceName the name of the survey instance
   */
  public ViewSurveyResultPage(PageReference previousPage, UUID surveyInstanceId,
      String surveyInstanceName)
  {
    super("View Survey Result", surveyInstanceName);

    try
    {
      SurveyResult surveyResult = surveyService.getSurveyResultForSurveyInstance(surveyInstanceId);

      add(new SurveyResultPanel("surveyResult", new Model<>(surveyResult)));

      // The "backLink" link
      Link<Void> backLink = new Link<Void>("backLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          setResponsePage(previousPage.getPage());
        }
      };
      add(backLink);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the ViewSurveyResultPage", e);
    }
  }
}
