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

package guru.mmp.survey.model;

//~--- JDK imports ------------------------------------------------------------

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.util.UUID;

/**
 * The <code>SurveyResponseGroupRatingItem</code> class implements the Survey Response Group Rating
 * Item entity, which represents the response for a group rating item for a particular group member
 * that forms part of a user's response to a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_RESPONSE_GROUP_RATING_ITEMS")
public class SurveyResponseGroupRatingItem
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey response group
   * rating item.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey response this
   * survey response group rating item is associated with.
   */
  @Column(name = "RESPONSE_ID", nullable = false)
  private UUID responseId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey template group
   * rating item this survey response group rating item is associated with.
   */
  @Column(name = "TEMPLATE_ITEM_ID", nullable = false)
  private UUID templateItemId;

  /**
   * The survey template group member this survey response group rating item is associated with.
   */
  @Column(name = "TEMPLATE_GROUP_MEMBER_ID", nullable = false)
  private UUID templateGroupMemberId;

  /**
   * The rating for the survey response group rating item e.g. 1=Yes, 0=No and -1=Not Applicable.
   */
  @Column(name = "RATING", nullable = false)
  private int rating;

  /**
   * Constructs a new <code>SurveyResponseGroupRatingItem</code>.
   */
  SurveyResponseGroupRatingItem() {}

  /**
   * Indicates whether some other object is "equal to" this one.
   *
   * @param obj the reference object with which to compare
   *
   * @return <code>true</code> if this object is the same as the obj argument otherwise
   *         <code>false</code>
   */
  @Override
  public boolean equals(Object obj)
  {
    if (this == obj)
    {
      return true;
    }

    if (obj == null)
    {
      return false;
    }

    if (getClass() != obj.getClass())
    {
      return false;
    }

    SurveyResponseGroupRatingItem other = (SurveyResponseGroupRatingItem) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   * group rating item.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   *         group rating item
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * @Column(name = "ID", nullable = false)
   * Returns the rating for the survey response group rating item e.g. 1=Yes, 0=No and
   * -1=Not Applicable.
   *
   * @return the rating for the survey response group rating item e.g. 1=Yes, 0=No and
   *         -1=Not Applicable
   */
  public int getRating()
  {
    return rating;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   * this survey response group rating item is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   *         this survey response group rating item is associated with
   */
  public UUID getResponseId()
  {
    return responseId;
  }

  /**
   * Returns the survey template group member this survey response group rating item is associated
   * with.
   *
   * @return the survey template group member this survey response group rating item is associated
   *         with
   */
  public UUID getTemplateGroupMemberId()
  {
    return templateGroupMemberId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group rating item this survey response group rating item is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   *         group rating item this survey response group rating item is associated with
   */
  public UUID getTemplateItemId()
  {
    return templateItemId;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   * group rating item.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           response group rating item
   */
  public void setId(UUID id)
  {
    this.id = id;
  }

  /**
   * Set the rating for the survey response group rating item e.g. 1=Yes, 0=No and
   * -1=Not Applicable.
   *
   * @param rating the rating for the survey response group rating item e.g. 1=Yes, 0=No and
   *               -1=Not Applicable
   */
  public void setRating(int rating)
  {
    this.rating = rating;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey response this
   * survey response group rating item is associated with.
   *
   * @param responseId the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                   response this survey response group rating item is associated with
   */
  public void setResponseId(UUID responseId)
  {
    this.responseId = responseId;
  }

  /**
   * Set the survey template group member this survey response group rating item is associated with.
   *
   * @param templateGroupMemberId the survey template group member this survey response group rating
   *                              item is associated with
   */
  public void setTemplateGroupMemberId(UUID templateGroupMemberId)
  {
    this.templateGroupMemberId = templateGroupMemberId;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group rating item this survey response group rating item is associated with.
   *
   * @param templateItemId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       survey template group rating item this survey response group rating item
   *                       is associated with
   */
  public void setTemplateItemId(UUID templateItemId)
  {
    this.templateItemId = templateItemId;
  }
}
