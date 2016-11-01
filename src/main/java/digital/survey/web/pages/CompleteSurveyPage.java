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
import digital.survey.model.SurveyRequest;
import digital.survey.model.SurveyResponse;
import digital.survey.web.components.SurveyResponseInputPanel;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.model.CompoundPropertyModel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>CompleteSurveyPage</code> class implements the "Complete Survey"
 * page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
public class CompleteSurveyPage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(CompleteSurveyPage.class);
  private static final long serialVersionUID = 1000000;

  /**
   * The Survey Service.
   */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>CompleteSurveyPage</code>.
   *
   * @param pageParameters the page parameters
   */
  public CompleteSurveyPage(PageParameters pageParameters)
  {
    super("Complete Survey");

    try
    {
      SurveyInstance surveyInstance = surveyService.getSurveyInstance(UUID.fromString(
          pageParameters.get("surveyInstanceId").toString()));

      SurveyRequest surveyRequest = null;

      if ((!pageParameters.get("surveyRequestId").isNull())
          && (!pageParameters.get("surveyRequestId").isEmpty()))
      {
        surveyRequest = surveyService.getSurveyRequest(UUID.fromString(pageParameters.get(
            "surveyRequestId").toString()));
      }
      else
      {
        // TODO: Check if the survey definition associated with the survey request allows anonymous responses -- MARCUS
      }

      SurveyResponse surveyResponse = new SurveyResponse(surveyInstance, surveyRequest);

      IModel<SurveyResponse> surveyResponseModel = new Model<>(surveyResponse);

      Form<SurveyResponse> completeSurveyForm = new Form<>("completeSurveyForm",
          new CompoundPropertyModel<>(surveyResponseModel));

      completeSurveyForm.add(new SurveyResponseInputPanel("surveyResponse", surveyResponseModel));

      // The "submitButton" button
      Button submitButton = new Button("submitButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit()
        {
          try
          {
            surveyService.saveSurveyResponse(completeSurveyForm.getModelObject());

            setVisible(false);

            CompleteSurveyPage.this.info("Successfully saved the survey response");
          }
          catch (Throwable e)
          {
            logger.error("Failed to save the survey response: " + e.getMessage(), e);
            CompleteSurveyPage.this.error("Failed to save the survey response");
          }
        }
      };
      submitButton.setDefaultFormProcessing(true);
      completeSurveyForm.add(submitButton);

      add(completeSurveyForm);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the CompleteSurveyPage", e);
    }
  }
}
