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
@JsonPropertyOrder({ "id", "groupRatingsDefinitionId", "groupRatingDefinitionId",
    "groupMemberDefinitionId", "rating" })
public class SurveyGroupRatingResponse extends SurveyItemResponse
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * response for the survey group rating response.
   */
  public static final UUID TYPE_ID = UUID.fromString("be86b4b4-492b-403f-a015-41a6d7554222");

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group member
   * definition this survey group rating response is associated with.
   */
  @JsonProperty
  private UUID groupMemberDefinitionId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating
   * definition this survey group rating response is associated with.
   */
  @JsonProperty
  private UUID groupRatingDefinitionId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group ratings
   * definition this survey group rating response is associated with.
   */
  @JsonProperty
  private UUID groupRatingsDefinitionId;

  /**
   * The rating for the survey group rating response e.g. 1=Yes, 0=No and -1=Not Applicable.
   */
  @JsonProperty
  private int rating;

  /**
   * Constructs a new <code>SurveyGroupRatingResponse</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingResponse() {}

  /**
   * Constructs a new <code>SurveyGroupRatingResponse</code>.
   *
   * @param groupRatingsDefinition the survey group ratings definition this survey group rating
   *                               response is associated with
   * @param groupRatingDefinition  the survey group rating definition this survey group rating
   *                               response is associated with
   * @param groupMemberDefinition  the survey group member definition this survey group rating
   *                               response is associated with
   */
  public SurveyGroupRatingResponse(SurveyGroupRatingsDefinition groupRatingsDefinition,
      SurveyGroupRatingDefinition groupRatingDefinition,
      SurveyGroupMemberDefinition groupMemberDefinition)
  {
    super(TYPE_ID);

    this.groupRatingsDefinitionId = groupRatingsDefinition.getId();
    this.groupRatingDefinitionId = groupRatingDefinition.getId();
    this.groupMemberDefinitionId = groupMemberDefinition.getId();
    this.rating = groupRatingDefinition.getRatingType().defaultRating();
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * member definition this survey group rating response is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         member definition this survey group rating response is associated with
   */
  public UUID getGroupMemberDefinitionId()
  {
    return groupMemberDefinitionId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating definition this survey group rating response is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating definition this survey group rating response is associated with
   */
  public UUID getGroupRatingDefinitionId()
  {
    return groupRatingDefinitionId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * ratings definition this survey group rating response is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         ratings definition this survey group rating response is associated with
   */
  public UUID getGroupRatingsDefinitionId()
  {
    return groupRatingsDefinitionId;
  }

  /**
   * Returns the rating for the survey group rating response e.g. 1=Yes, 0=No and
   * -1=Not Applicable.
   *
   * @return the rating for the survey group rating response e.g. 1=Yes, 0=No and
   *         -1=Not Applicable
   */
  public int getRating()
  {
    return rating;
  }

  /**
   * Set the rating for the survey group rating response e.g.
   * 1=Yes, 0=No and -1=Not Applicable.
   *
   * @param rating the rating for the survey group rating response e.g. 1=Yes, 0=No and
   *               -1=Not Applicable
   */
  public void setRating(int rating)
  {
    this.rating = rating;
  }

  /**
   * Returns the String representation of the survey group rating response.
   *
   * @return the String representation of the survey group rating response
   */
  @Override
  public String toString()
  {
    return String.format("SurveyGroupRatingResponse {id=\"%s\", groupRatingsDefinitionId=\"%s\", "
        + "groupRatingDefinitionId=\"%s\", groupMemberDefinitionId=\"%s\"}", getId(),
        getGroupRatingsDefinitionId(), getGroupRatingDefinitionId(), getGroupMemberDefinitionId());
  }
}
