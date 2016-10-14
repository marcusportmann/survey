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

import javax.persistence.*;
import java.util.UUID;

/**
 * The <code>SurveyTemplateGroupRatingItem</code> class implements the Survey Template Group Rating
 * Item entity, which represents represents a group rating item that forms part of a template for a
 * survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_TEMPLATE_GROUP_RATING_ITEMS")
public class SurveyTemplateGroupRatingItem
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey template group
   * rating item.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The name of the survey template group rating item.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The survey template this survey template group rating item is associated with.
   */
  @ManyToOne
  @JoinColumn(name = "SURVEY_TEMPLATE_ID")
  private SurveyTemplate template;

  /**
   * The survey template group this survey template group rating item is associated with.
   */
  @ManyToOne(cascade = { CascadeType.MERGE })
  @JoinColumn(name = "SURVEY_TEMPLATE_GROUP_ID")
  private SurveyTemplateGroup group;

  /**
   * The numeric code giving the type of survey template group rating e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   */
  @Column(name = "RATING_TYPE", nullable = false)
  @Convert(converter = SurveyTemplateGroupRatingTypeConverter.class)
  private SurveyTemplateGroupRatingType ratingType;

  /**
   * Constructs a new <code>SurveyTemplateGroupRatingItem</code>.
   */
  SurveyTemplateGroupRatingItem() {}

  /**
   * Constructs a new <code>SurveyTemplateGroupRatingItem</code>.
   *
   * @param id         the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                   template group rating item
   * @param name       the name of the survey template group rating item
   * @param group      the survey template group this survey template group rating item is
   *                   associated with
   * @param ratingType the numeric code giving the type of survey template group rating
   *                   e.g. 1 = Percentage, 2 = Yes/No/NA, etc
   */
  public SurveyTemplateGroupRatingItem(UUID id, String name, SurveyTemplateGroup group,
      SurveyTemplateGroupRatingType ratingType)
  {
    this.id = id;
    this.name = name;
    this.group = group;

    // this.groupId = group.getId();
    this.ratingType = ratingType;
  }

///**
// * Constructs a new <code>SurveyTemplateGroupRatingItem</code>.
// *
// * @param id         the Universally Unique Identifier (UUID) used to uniquely identify the survey
// *                   template group rating item
// * @param name       the name of the survey template group rating item
// * @param groupId    the Universally Unique Identifier (UUID) used to uniquely identify the survey
// *                   template group this survey template group rating item is associated with
// * @param ratingType the numeric code giving the type of survey template group rating
// *                   e.g. 1 = Percentage, 2 = Yes/No/NA, etc
// */
//public SurveyTemplateGroupRatingItem(UUID id, String name, UUID groupId,
//    SurveyTemplateGroupRatingType ratingType)
//{
//  this.id = id;
//  this.name = name;
//  this.groupId = groupId;
//  this.ratingType = ratingType;
//}

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

    SurveyTemplateGroupRatingItem other = (SurveyTemplateGroupRatingItem) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the survey template group this survey template group rating item is associated with.
   *
   * @return the survey template group this survey template group rating item is associated with
   */
  public SurveyTemplateGroup getGroup()
  {
    return group;
  }

///**
// * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template
// * group this survey template group rating item is associated with.
// *
// * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
// *         group this survey template group rating item is associated with
// */
//public UUID getGroupId()
//{
//  return groupId;
//}

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group rating item.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   *         group rating item
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey template group rating item.
   *
   * @return the name of the survey template group rating item
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the numeric code giving the type of survey template group rating e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   *
   * @return the numeric code giving the type of survey template group rating e.g. 1 = Percentage,
   *         2 = Yes/No/NA, etc
   */
  public SurveyTemplateGroupRatingType getRatingType()
  {
    return ratingType;
  }

  /**
   * Set the survey template group this survey template group rating item is associated with.
   *
   * @param group the survey template group this survey template group rating item is associated with
   */
  public void setGroup(SurveyTemplateGroup group)
  {
    this.group = group;
  }

///**
// * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey template
// * group this survey template group rating item is associated with
// *
// * @param groupId the Universally Unique Identifier (UUID) used to uniquely identify the survey
// *                template group this survey template group rating item is associated with
// */
//public void setGroupId(UUID groupId)
//{
//  this.groupId = groupId;
//}

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group rating item.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template group rating item
   */
  public void setId(UUID id)
  {
    this.id = id;
  }

  /**
   * Set the name of the survey template group rating item.
   *
   * @param name the name of the survey template group rating item
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Set the numeric code giving the type of survey template group rating e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   *
   * @param ratingType the numeric code giving the type of survey template group rating
   *                   e.g. 1 = Percentage, 2 = Yes/No/NA, etc
   */
  public void setRatingType(SurveyTemplateGroupRatingType ratingType)
  {
    this.ratingType = ratingType;
  }

  /**
   * Set the survey template this survey template group rating item is associated with.
   *
   * @param template the survey template this survey template group rating item is associated with
   */
  public void setTemplate(SurveyTemplate template)
  {
    this.template = template;
  }

  /**
   * Returns the String representation of the survey template group rating item.
   *
   * @return the String representation of the survey template group rating item
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyTemplateGroupRatingItem {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("ratingType=\"").append(getRatingType().description()).append("\"");
    buffer.append("}");

    return buffer.toString();
  }
}
