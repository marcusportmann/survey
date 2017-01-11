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
 * The <code>SurveyGroupRatingResult</code> class implements the Survey Group Rating Result entity,
 * which represents the result for a survey group rating compiled from the users' responses to a
 * survey.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "groupRatingsDefinitionId", "groupRatingDefinitionId",
    "groupRatingDefinitionRatingType", "groupMemberDefinitionId", "averageRating", "ratings" })
public class SurveyGroupRatingResult
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group member
   * definition this survey group rating result is associated with.
   */
  @JsonProperty
  private UUID groupMemberDefinitionId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating
   * definition this survey group rating result is associated with.
   */
  @JsonProperty
  private UUID groupRatingDefinitionId;

  /**
   * The type of survey group rating.
   */
  @JsonProperty
  private SurveyGroupRatingType groupRatingDefinitionRatingType;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group ratings
   * definition this survey group rating result is associated with.
   */
  @JsonProperty
  private UUID groupRatingsDefinitionId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating
   * result.
   */
  @JsonProperty
  private UUID id;

  /**
   * The ratings for the survey group rating result.
   */
  @JsonProperty
  private List<Integer> ratings;

  /**
   * Constructs a new <code>SurveyGroupRatingResult</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingResult() {}

  /**
   * Constructs a new <code>SurveyGroupRatingResult</code>.
   *
   * @param groupRatingsDefinition the survey group ratings definition this survey group rating
   *                               result is associated with
   * @param groupRatingDefinition  the survey group rating definition this survey group rating
   *                               result is associated with
   * @param groupMemberDefinition  the survey group member definition this survey group rating
   *                               result is associated with
   */
  public SurveyGroupRatingResult(SurveyGroupRatingsDefinition groupRatingsDefinition,
      SurveyGroupRatingDefinition groupRatingDefinition,
      SurveyGroupMemberDefinition groupMemberDefinition)
  {
    this.id = UUID.randomUUID();
    this.groupRatingsDefinitionId = groupRatingsDefinition.getId();
    this.groupRatingDefinitionId = groupRatingDefinition.getId();
    this.groupRatingDefinitionRatingType = groupRatingDefinition.getRatingType();
    this.groupMemberDefinitionId = groupMemberDefinition.getId();
    this.ratings = new ArrayList<>();
  }

  /**
   * Add the rating for the survey group rating result.
   *
   * @param rating the rating for the survey group rating result
   */
  public void addRating(int rating)
  {
    ratings.add(rating);
  }

  /**
   * Returns the average rating for the survey group rating result.
   *
   * @return the average rating for the survey group rating result
   */
  @JsonProperty
  public float getAverageRating()
  {
    if (groupRatingDefinitionRatingType == SurveyGroupRatingType.ONE_TO_TEN)
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
    else if (groupRatingDefinitionRatingType == SurveyGroupRatingType.YES_NO_NA)
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
   * member definition this survey group rating result is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         member definition this survey group rating result is associated with
   */
  public UUID getGroupMemberDefinitionId()
  {
    return groupMemberDefinitionId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating definition this survey group rating result is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating definition this survey group rating result is associated with
   */
  public UUID getGroupRatingDefinitionId()
  {
    return groupRatingDefinitionId;
  }

  /**
   * Returns the type of survey group rating.
   *
   * @return the type of survey group rating
   */
  public SurveyGroupRatingType getGroupRatingDefinitionRatingType()
  {
    return groupRatingDefinitionRatingType;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * ratings definition this survey group rating result is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         ratings definition this survey group rating result is associated with
   */
  public UUID getGroupRatingsDefinitionId()
  {
    return groupRatingsDefinitionId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating result.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating result
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
    if (groupRatingDefinitionRatingType == SurveyGroupRatingType.ONE_TO_TEN)
    {
      return ratings.size();
    }
    else if (groupRatingDefinitionRatingType == SurveyGroupRatingType.YES_NO_NA)
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
   * Returns the ratings for the survey group rating result.
   *
   * @return the ratings for the survey group rating result
   */
  public List<Integer> getRatings()
  {
    return ratings;
  }
}
