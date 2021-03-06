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

import guru.mmp.application.web.template.components.InputPanel;
import guru.mmp.application.web.template.components.TextFieldWithFeedback;
import org.apache.wicket.markup.html.form.TextField;

/**
 * The <code>SurveyAudienceInputPanel</code> class provides a Wicket component that can
 * be used to capture the information for a <code>SurveyAudience</code>.
 *
 * @author Marcus Portmann
 */
public class SurveyAudienceInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyAudienceInputPanel</code>.
   *
   * @param id the non-null id of this component
   */
  public SurveyAudienceInputPanel(String id)
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
  }
}
