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

import digital.survey.model.SurveyResponse;
import digital.survey.model.SurveyResult;
import digital.survey.model.SurveyTextDefinition;
import digital.survey.model.SurveyTextResponse;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

/**
 * The <code>SurveyTextResultPanel</code> class.
 *
 * @author Marcus Portmann
 */
class SurveyTextResultPanel extends Panel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyTextResultPanel</code>.
   *
   * @param id                        the non-null id of this component
   * @param surveyTextDefinitionModel the model for the survey text definition
   * @param surveyResultModel         the model for the survey result
   */
  SurveyTextResultPanel(String id, IModel<SurveyTextDefinition> surveyTextDefinitionModel,
    IModel<SurveyResult> surveyResultModel)
  {
    super(id);

    setRenderBodyOnly(true);

    SurveyResult surveyResult = surveyResultModel.getObject();

    SurveyTextDefinition textDefinition = surveyTextDefinitionModel.getObject();

//    List<SurveyTextResult> textResults = surveyResponse.getTextResultsForDefinition(
//      textDefinition.getId());
  }
}
