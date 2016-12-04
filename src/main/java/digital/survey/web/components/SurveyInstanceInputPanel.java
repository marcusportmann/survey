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

package digital.survey.web.components;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.SurveyInstance;
import digital.survey.web.SurveyApplication;
import guru.mmp.application.configuration.IConfigurationService;
import guru.mmp.application.web.template.components.InputPanel;
import guru.mmp.application.web.template.components.TextFieldWithFeedback;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;

import javax.inject.Inject;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyInstanceInputPanel</code> class provides a Wicket component that can
 * be used to capture the information for a <code>SurveyInstance</code>.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
public class SurveyInstanceInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /* Configuration Service */
  @Inject
  private IConfigurationService configurationService;

  /**
   * Constructs a new <code>SurveyInstanceInputPanel</code>.
   *
   * @param id                  the non-null id of this component
   * @param surveyInstanceModel the model for the survey instance
   */
  public SurveyInstanceInputPanel(String id, IModel<SurveyInstance> surveyInstanceModel)
  {
    super(id);

    // The "name" field
    TextField<String> nameField = new TextFieldWithFeedback<>("name");
    nameField.setRequired(true);
    add(nameField);

    // The "description" field
    TextField<String> descriptionField = new TextFieldWithFeedback<>("description");
    descriptionField.setRequired(true);
    add(descriptionField);

    WebMarkupContainer urlContainer = new WebMarkupContainer("urlContainer");
    urlContainer.setVisible(false);
    add(urlContainer);

    String completeSurveyResponseUrl = "";

    SurveyInstance surveyInstance = surveyInstanceModel.getObject();

    if (surveyInstance.getDefinition().isAnonymous())
    {
      try
      {
        completeSurveyResponseUrl = configurationService.getString(SurveyApplication
            .COMPLETE_SURVEY_RESPONSE_URL_CONFIGURATION_KEY);

        completeSurveyResponseUrl += "?surveyInstanceId=";
        completeSurveyResponseUrl += surveyInstance.getId();
      }
      catch (Throwable e)
      {
        completeSurveyResponseUrl = "Failed to determine the URL to complete the anonymous survey";
      }

      urlContainer.setVisible(true);
    }

    // The "url" field
    TextField<String> urlField = new TextField<>("url", new Model<>(completeSurveyResponseUrl));
    urlField.setRequired(false);
    urlField.setEnabled(false);
    urlContainer.add(urlField);
  }
}
