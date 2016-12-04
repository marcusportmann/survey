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
import digital.survey.model.SurveyResponse;
import digital.survey.web.SurveySecurity;
import digital.survey.web.components.SurveyResponseReadOnlyPanel;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.PageReference;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.model.IModel;

import javax.inject.Inject;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>ViewSurveyResponsePage</code> class implements the "View Survey Response"
 * page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity({ SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION,
    SurveySecurity.FUNCTION_CODE_VIEW_SURVEY_RESPONSE })
public class ViewSurveyResponsePage extends TemplateWebPage
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Survey Service.
   */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>ViewSurveyResponsePage</code>.
   *
   * @param previousPage        the previous page
   * @param surveyResponseModel the model for the survey response
   */
  public ViewSurveyResponsePage(PageReference previousPage,
      IModel<SurveyResponse> surveyResponseModel)
  {
    super("View Survey Response", surveyResponseModel.getObject().getName());

    try
    {
      // The "backTopLink" link
      Link<Void> backTopLink = new Link<Void>("backTopLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          setResponsePage(previousPage.getPage());
        }
      };
      add(backTopLink);

      // The "surveyResponse" panel
      add(new SurveyResponseReadOnlyPanel("surveyResponse", surveyResponseModel));

      // The "backBottomLink" link
      Link<Void> backBottomLink = new Link<Void>("backBottomLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          setResponsePage(previousPage.getPage());
        }
      };
      add(backBottomLink);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the ViewSurveyResponsePage", e);
    }
  }
}
