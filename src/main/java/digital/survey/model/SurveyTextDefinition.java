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

package digital.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.io.Serializable;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyTextDefinition</code> class implements the Survey Text Definition entity, which
 * represents the definition for a text value that can be captured for a survey.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "typeId", "name", "label", "description", "help" })
public class SurveyTextDefinition extends SurveyItemDefinition
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition for the survey text definition.
   */
  public static final UUID TYPE_ID = UUID.fromString("491253d9-e6cf-4692-bcfd-39bcd8960a60");

  /**
   * Constructs a new <code>SurveyTextDefinition</code>.
   */
  @SuppressWarnings("unused")
  SurveyTextDefinition() {}

  /**
   * Constructs a new <code>SurveyTextDefinition</code>.
   *
   * @param name        the short, unique name for the survey text definition
   * @param label       the user-friendly label for the survey text definition
   * @param description the description for the survey text definition
   * @param help        the HTML help for the survey text definition
   */
  public SurveyTextDefinition(String name, String label, String description, String help)
  {
    super(TYPE_ID, name, label, description, help);
  }
}
