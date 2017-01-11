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

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.io.Serializable;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingResponse</code> class implements the Survey Group Rating Response
 * entity, which represents the response for a survey group rating that forms part of a survey
 * response.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "typeId", "definitionId", "value" })
public class SurveyTextResponse extends SurveyItemResponse
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * response for the survey text response.
   */
  public static final UUID TYPE_ID = UUID.fromString("293a0354-07bf-4db0-8863-ab0d73a6c15b");

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey text definition
   * this survey text response is associated with.
   */
  @JsonProperty
  private UUID definitionId;

  /**
   * The value for the survey text response.
   */
  @JsonProperty
  private String value;

  /**
   * Constructs a new <code>SurveyTextResponse</code>.
   */
  @SuppressWarnings("unused")
  SurveyTextResponse() {}

  /**
   * Constructs a new <code>SurveyTextResponse</code>.
   *
   * @param definition the survey text definition this survey text response is associated with
   */
  public SurveyTextResponse(SurveyTextDefinition definition)
  {
    super(TYPE_ID);

    this.definitionId = definition.getId();
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey text
   * definition this survey text response is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey text
   *         definition this survey text response is associated with
   */
  public UUID getDefinitionId()
  {
    return definitionId;
  }

  /**
   * Returns the value for the survey text response.
   *
   * @return the value for the survey text response
   */
  public String getValue()
  {
    return value;
  }

  /**
   * Set the value for the survey text response.
   *
   * @param value the value for the survey text response
   */
  public void setValue(String value)
  {
    this.value = value;
  }
}
