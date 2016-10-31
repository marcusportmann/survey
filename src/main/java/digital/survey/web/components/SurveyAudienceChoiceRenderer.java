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

import digital.survey.model.SurveyAudience;
import org.apache.wicket.markup.html.form.IChoiceRenderer;
import org.apache.wicket.model.IModel;

import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyAudienceChoiceRenderer</code> class implements a
 * <code>ChoiceRenderer</code> for <code>SurveyAudience</code> instances.
 *
 * @author Marcus Portmann
 */
public class SurveyAudienceChoiceRenderer
  implements IChoiceRenderer<SurveyAudience>
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyAudienceChoiceRenderer</code>.
   */
  public SurveyAudienceChoiceRenderer() {}

  /**
   * Get the value for displaying to an end user.
   *
   * @param type the survey group rating item type
   *
   * @return the value meant for displaying to an end user
   */
  public Object getDisplayValue(SurveyAudience type)
  {
    return type.getName();
  }

  /**
   * This method is called to get the id value of a job status (used as the value attribute
   * of a choice element).
   *
   * @param type  the survey group rating item type for which the id should be generated
   * @param index the index of the object in the choices list
   *
   * @return the id value of the object
   */
  public String getIdValue(SurveyAudience type, int index)
  {
    return type.getId().toString();
  }

  /**
   * This method is called to get an object back from its id representation. The id may be used to
   * find/load the object in a more efficient way than loading all choices and find the one with
   * the same id in the list.
   *
   * @param id      the id representation of the object
   * @param choices the model providing the list of all rendered choices
   *
   * @return a choice from the list that has this id
   */
  public SurveyAudience getObject(String id,
      IModel<? extends List<? extends SurveyAudience>> choices)
  {
    for (SurveyAudience surveyAudience : choices.getObject())
    {
      if (surveyAudience.getId().equals(UUID.fromString(id)))
      {
        return surveyAudience;
      }
    }

    return null;
  }
}
