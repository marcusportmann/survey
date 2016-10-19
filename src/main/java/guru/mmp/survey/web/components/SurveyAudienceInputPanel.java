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

package guru.mmp.survey.web.components;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.web.template.components.InputPanel;
import guru.mmp.application.web.template.components.TextFieldWithFeedback;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.form.upload.FileUpload;
import org.apache.wicket.markup.html.form.upload.FileUploadField;
import org.apache.wicket.model.PropertyModel;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

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
   * @param id           the non-null id of this component
   * @param isIdReadOnly <code>true</code> if the ID for the <code>SurveyAudience</code>
   *                     is readonly or <code>false</code> otherwise
   */
  public SurveyAudienceInputPanel(String id, boolean isIdReadOnly)
  {
    super(id);

    // The "id" field
    TextField<String> idField = new TextFieldWithFeedback<>("id");
    idField.setRequired(true);
    idField.setEnabled(!isIdReadOnly);
    add(idField);

    // The "name" field
    TextField<String> nameField = new TextFieldWithFeedback<>("name");
    nameField.setRequired(true);
    add(nameField);
  }
}
