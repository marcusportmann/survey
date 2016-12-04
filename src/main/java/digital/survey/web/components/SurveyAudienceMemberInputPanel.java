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
 * The <code>SurveyAudienceMemberInputPanel</code> class provides a Wicket component that can
 * be used to capture the information for a <code>SurveyAudienceMember</code>.
 *
 * @author Marcus Portmann
 */
public class SurveyAudienceMemberInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyAudienceMemberInputPanel</code>.
   *
   * @param id the non-null id of this component
   */
  public SurveyAudienceMemberInputPanel(String id)
  {
    super(id);

    // The "firstName" field
    TextField<String> firstNameField = new TextFieldWithFeedback<>("firstName");
    firstNameField.setRequired(true);
    add(firstNameField);

    // The "lastName" field
    TextField<String> lastNameField = new TextFieldWithFeedback<>("lastName");
    lastNameField.setRequired(true);
    add(lastNameField);

    // The "email" field
    TextField<String> emailField = new TextFieldWithFeedback<>("email");
    emailField.setRequired(true);
    add(emailField);
  }
}
