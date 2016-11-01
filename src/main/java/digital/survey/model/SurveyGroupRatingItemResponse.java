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
 * The <code>SurveyGroupRatingItemResponse</code> class implements the Survey Group Rating Item
 * Response entity, which represents the response for a group rating item that forms part of a
 * survey response.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "groupRatingItemDefinitionId", "groupRatingItemDefinitionName",
    "groupRatingItemDefinitionRatingType", "groupMemberDefinitionId", "groupMemberDefinitionName",
    "rating" })
public class SurveyGroupRatingItemResponse
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating item
   * response.
   */
  @JsonProperty
  private UUID id;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group member
   * definition this survey group rating item response is associated with.
   */
  @JsonProperty
  private UUID groupMemberDefinitionId;

  /**
   * The name of the survey group member definition.
   */
  @JsonProperty
  private String groupMemberDefinitionName;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating item
   * definition this survey group rating item response is associated with.
   */
  @JsonProperty
  private UUID groupRatingItemDefinitionId;

  /**
   * The name of the survey group rating item definition.
   */
  @JsonProperty
  private String groupRatingItemDefinitionName;

  /**
   * The type of survey group rating item.
   */
  @JsonProperty
  private SurveyGroupRatingItemType groupRatingItemDefinitionRatingType;

  /**
   * The rating for the survey group rating item response e.g. 1=Yes, 0=No and -1=Not Applicable.
   */
  @JsonProperty
  private int rating;

  /**
   * Constructs a new <code>SurveyGroupRatingItemResponse</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingItemResponse() {}

  /**
   * Constructs a new <code>SurveyGroupRatingItemResponse</code>.
   *
   * @param groupRatingItemDefinition the survey group rating item definition this survey group
   *                                  rating item response is associated with
   * @param groupMemberDefinition     the survey group member definition this survey group rating
   *                                  item response is associated with
   */
  public SurveyGroupRatingItemResponse(SurveyGroupRatingItemDefinition groupRatingItemDefinition,
      SurveyGroupMemberDefinition groupMemberDefinition)
  {
    this.id = UUID.randomUUID();
    this.groupRatingItemDefinitionId = groupRatingItemDefinition.getId();
    this.groupRatingItemDefinitionName = groupRatingItemDefinition.getName();
    this.groupRatingItemDefinitionRatingType = groupRatingItemDefinition.getRatingType();
    this.groupMemberDefinitionId = groupMemberDefinition.getId();
    this.groupMemberDefinitionName = groupMemberDefinition.getName();
    this.rating = groupRatingItemDefinition.getRatingType().defaultRating();
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * member definition this survey group rating item response is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         member definition this survey group rating item response is associated with
   */
  public UUID getGroupMemberDefinitionId()
  {
    return groupMemberDefinitionId;
  }

  /**
   * Returns the name of the survey group member definition.
   *
   * @return the name of the survey group member definition
   */
  public String getGroupMemberDefinitionName()
  {
    return groupMemberDefinitionName;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating item definition this survey group rating item response is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating item definition this survey group rating item response is associated with
   */
  public UUID getGroupRatingItemDefinitionId()
  {
    return groupRatingItemDefinitionId;
  }

  /**
   * Returns the name of the survey group rating item definition this survey group rating item
   * response is associated with.
   *
   * @return the name of the survey group rating item definition this survey group rating item
   *         response is associated with
   */
  public String getGroupRatingItemDefinitionName()
  {
    return groupRatingItemDefinitionName;
  }

  /**
   * Returns the type of survey group rating item.
   *
   * @return the type of survey group rating item
   */
  public SurveyGroupRatingItemType getGroupRatingItemDefinitionRatingType()
  {
    return groupRatingItemDefinitionRatingType;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating item response.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating item response
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the rating for the survey group rating item response e.g. 1=Yes, 0=No and
   * -1=Not Applicable.
   *
   * @return the rating for the survey group rating item response e.g. 1=Yes, 0=No and
   *         -1=Not Applicable
   */
  public int getRating()
  {
    return rating;
  }

  /**
   * Set the rating for the survey group rating item response e.g.
   * 1=Yes, 0=No and -1=Not Applicable.
   *
   * @param rating the rating for the survey group rating item response e.g. 1=Yes, 0=No and
   *               -1=Not Applicable
   */
  public void setRating(int rating)
  {
    this.rating = rating;
  }

  /**
   * Returns the String representation of the survey definition.
   *
   * @return the String representation of the survey definition
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyGroupRatingItemResponse {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("groupMemberDefinitionId=\"").append(getGroupMemberDefinitionId()).append("\", ");
    buffer.append("groupMemberDefinitionName=\"").append(getGroupMemberDefinitionName()).append(
        "\", ");
    buffer.append("groupRatingItemDefinitionId=\"").append(getGroupRatingItemDefinitionId()).append(
        "\", ");
    buffer.append("groupRatingItemDefinitionName=\"").append(getGroupRatingItemDefinitionName())
        .append("\", ");
    buffer.append("groupRatingItemDefinitionRatingType=\"").append(
        getGroupRatingItemDefinitionRatingType()).append("\"");

    return buffer.toString();
  }
}
