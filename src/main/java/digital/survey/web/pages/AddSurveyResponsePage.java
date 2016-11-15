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
import digital.survey.model.SurveyResponse;
import digital.survey.web.SurveySecurity;
import digital.survey.web.components.SurveyResponseInputPanel;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.PageReference;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.model.CompoundPropertyModel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import java.util.Date;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>AddSurveyResponsePage</code> class implements the "Add Survey Response"
 * page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity(SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION)
public class AddSurveyResponsePage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(AddSurveyResponsePage.class);
  private static final long serialVersionUID = 1000000;

  /**
   * The Survey Service.
   */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>AddSurveyResponsePage</code>.
   *
   * @param previousPage       the previous page
   * @param surveyInstanceId   the Universally Unique Identifier (UUID) used to identify the survey
   *                           instance the survey responses are associated with
   * @param surveyInstanceName the name of the survey instance
   */
  public AddSurveyResponsePage(PageReference previousPage, UUID surveyInstanceId,
      String surveyInstanceName)
  {
    super("Add Survey Response", surveyInstanceName);

    try
    {
      SurveyInstance surveyInstance = surveyService.getSurveyInstance(surveyInstanceId);

      IModel<SurveyResponse> surveyResponseModel = new Model<>(new SurveyResponse(surveyInstance));

      Form<SurveyResponse> addForm = new Form<>("addForm", new CompoundPropertyModel<>(
          surveyResponseModel));

      addForm.add(new SurveyResponseInputPanel("surveyResponse", surveyResponseModel));

      // The "addButton" button
      Button addButton = new Button("addButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit()
        {
          try
          {
            SurveyResponse surveyResponse = addForm.getModelObject();

            surveyResponse.setResponded(new Date());

            surveyService.saveSurveyResponse(surveyResponse);

            setResponsePage(previousPage.getPage());
          }
          catch (Throwable e)
          {
            logger.error("Failed to add the survey response: " + e.getMessage(), e);
            AddSurveyResponsePage.this.error("Failed to add the survey response");
          }
        }
      };
      addButton.setDefaultFormProcessing(true);
      addForm.add(addButton);

      // The "cancelButton" button
      Button cancelButton = new Button("cancelButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit()
        {
          setResponsePage(previousPage.getPage());
        }
      };
      cancelButton.setDefaultFormProcessing(false);
      addForm.add(cancelButton);

      add(addForm);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the AddSurveyResponsePage", e);
    }
  }
}
