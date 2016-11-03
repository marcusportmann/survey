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
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingItemDefinition</code> class implements the Survey Group Rating Item
 * Result entity, which represents the result for a group rating item compiled from the users
 * responses' to a survey.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "groupRatingItemDefinitionId", "groupRatingItemDefinitionRatingType",
    "groupMemberDefinitionId", "averageRating", "ratings" })
public class SurveyGroupRatingItemResult
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating item
   * result.
   */
  @JsonProperty
  private UUID id;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group member
   * definition this survey group rating item result is associated with.
   */
  @JsonProperty
  private UUID groupMemberDefinitionId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating item
   * definition this survey group rating item result is associated with.
   */
  @JsonProperty
  private UUID groupRatingItemDefinitionId;

  /**
   * The type of survey group rating item.
   */
  @JsonProperty
  private SurveyGroupRatingItemType groupRatingItemDefinitionRatingType;

  /**
   * The ratings for the survey group rating item result.
   */
  @JsonProperty
  private List<Integer> ratings;

  /**
   * Constructs a new <code>SurveyGroupRatingItemResult</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingItemResult() {}

  /**
   * Constructs a new <code>SurveyGroupRatingItemResult</code>.
   *
   * @param groupRatingItemDefinition the survey group rating item definition this survey group
   *                                  rating item result is associated with
   * @param groupMemberDefinition     the survey group member definition this survey group rating
   *                                  item result is associated with
   */
  public SurveyGroupRatingItemResult(SurveyGroupRatingItemDefinition groupRatingItemDefinition,
      SurveyGroupMemberDefinition groupMemberDefinition)
  {
    this.id = UUID.randomUUID();
    this.groupRatingItemDefinitionId = groupRatingItemDefinition.getId();
    this.groupRatingItemDefinitionRatingType = groupRatingItemDefinition.getRatingType();
    this.groupMemberDefinitionId = groupMemberDefinition.getId();
    this.ratings = new ArrayList<>();
  }

  /**
   * Add the rating for the survey group rating item result.
   *
   * @param rating the rating for the survey group rating item result
   */
  public void addRating(int rating)
  {
    ratings.add(rating);
  }

  /**
   * Returns the average rating for the survey group rating item result.
   *
   * @return the average rating for the survey group rating item result
   */
  @JsonProperty
  public float getAverageRating()
  {
    if (groupRatingItemDefinitionRatingType == SurveyGroupRatingItemType.ONE_TO_TEN)
    {
      if (ratings.size() == 0)
      {
        return 0;
      }

      int total = 0;

      for (int rating : ratings)
      {
        total += rating;
      }

      return ((float) total / (float) ratings.size());
    }
    else if (groupRatingItemDefinitionRatingType == SurveyGroupRatingItemType.YES_NO_NA)
    {
      float total = 0;

      for (int rating : ratings)
      {
        if (rating == -1)
        {
          total += 0.5;
        }
        else
        {
          total += rating;
        }
      }

      return (((float) total / (float) ratings.size()) * 100);
    }
    else
    {
      return 0;
    }
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * member definition this survey group rating item result is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         member definition this survey group rating item result is associated with
   */
  public UUID getGroupMemberDefinitionId()
  {
    return groupMemberDefinitionId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating item definition this survey group rating item result is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating item definition this survey group rating item result is associated with
   */
  public UUID getGroupRatingItemDefinitionId()
  {
    return groupRatingItemDefinitionId;
  }

  /**
   * Returns the type of survey group rating igroupRatingItemDefinitionRatingTypetem.
   *
   * @return the type of survey group rating item
   */
  public SurveyGroupRatingItemType getGroupRatingItemDefinitionRatingType()
  {
    return groupRatingItemDefinitionRatingType;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating item result.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating item result
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the number of ratings with a valid score.
   *
   * @return the number of ratings with a valid score
   */
  public int getNumberOfRatingsWithValidScore()
  {
    if (groupRatingItemDefinitionRatingType == SurveyGroupRatingItemType.ONE_TO_TEN)
    {
      return ratings.size();
    }
    else if (groupRatingItemDefinitionRatingType == SurveyGroupRatingItemType.YES_NO_NA)
    {
      int numberOfRatings = 0;

      for (int rating : ratings)
      {
        if (rating != -1)
        {
          numberOfRatings++;
        }
      }

      return numberOfRatings;
    }
    else
    {
      return ratings.size();
    }
  }

  /**
   * Returns the ratings for the survey group rating item result.
   *
   * @return the ratings for the survey group rating item result
   */
  public List<Integer> getRatings()
  {
    return ratings;
  }
}
