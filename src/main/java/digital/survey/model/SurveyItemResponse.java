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
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

import java.io.Serializable;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyItemResponse</code> implements the Survey Item Response entity, which
 * represents the response for a survey item that forms part of a survey response.
 *
 * @author Marcus Portmann
 */
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.PROPERTY, property = "typeId")
@JsonSubTypes({ @JsonSubTypes.Type(name = "be86b4b4-492b-403f-a015-41a6d7554222",
    value = SurveyGroupRatingResponse.class) ,
    @JsonSubTypes.Type(name = "293a0354-07bf-4db0-8863-ab0d73a6c15b",
        value = SurveyTextResponse.class) })
@JsonPropertyOrder({ "id", "typeId" })
public class SurveyItemResponse
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey item response.
   */
  @JsonProperty
  private UUID id;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * response.
   */
  @JsonProperty
  private UUID typeId;

  /**
   * Constructs a new <code>SurveyGroupRatingResponse</code>.
   */
  @SuppressWarnings("unused")
  SurveyItemResponse() {}

  /**
   * Constructs a new <code>SurveyItemResponse</code>.
   *
   * @param typeId the Universally Unique Identifier (UUID) used to uniquely identify the type of
   *               survey item response
   */
  public SurveyItemResponse(UUID typeId)
  {
    this.id = UUID.randomUUID();
    this.typeId = typeId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey item
   * response.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey item
   *         response
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the type of survey
   * item response.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the type of survey
   *         item response
   */
  public UUID getTypeId()
  {
    return typeId;
  }

  /**
   * Returns the String representation of the survey item response.
   *
   * @return the String representation of the survey item response
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyItemResponse {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("typeId=\"").append(getTypeId()).append("\"}");

    return buffer.toString();
  }
}
