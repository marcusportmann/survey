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

package guru.mmp.survey.web.pages;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import guru.mmp.survey.model.ISurveyService;
import guru.mmp.survey.model.SurveyInstance;
import guru.mmp.survey.model.SurveyRequest;
import guru.mmp.survey.model.SurveyResponse;
import guru.mmp.survey.web.SurveySecurity;
import guru.mmp.survey.web.components.SurveyResponseInputPanel;
import guru.mmp.survey.web.components.SurveyResponseReadOnlyPanel;
import org.apache.wicket.PageReference;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.model.CompoundPropertyModel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.request.mapper.parameter.PageParameters;

import javax.inject.Inject;
import java.util.UUID;

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
   * @param surveyResponseModel the model for the code
   */
  public ViewSurveyResponsePage(PageReference previousPage, IModel<SurveyResponse> surveyResponseModel)
  {
    super("View Survey Response", surveyResponseModel.getObject().getName());

    try
    {
      add(new SurveyResponseReadOnlyPanel("surveyResponse", surveyResponseModel));

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
      throw new WebApplicationException("Failed to initialise the ViewSurveyResponsePage", e);
    }
  }
}
