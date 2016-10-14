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
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;
import java.util.function.Predicate;

/**
 * The <code>SurveyTemplate</code> class implements the Survey Template entity, which represents
 * the template for a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_TEMPLATES")
public class SurveyTemplate
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey template.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The name of the survey template.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The description for the survey template.
   */
  @Column(name = "DESCRIPTION", nullable = false)
  private String description;

  /**
   * The groups of entities that are associated with a survey template.
   */
  @OneToMany(mappedBy = "template", cascade = CascadeType.ALL, fetch = FetchType.EAGER,
      orphanRemoval = true)
  @OrderBy("NAME ASC")
  private Set<SurveyTemplateGroup> groups;

  /**
   * The group rating items that are associated with a survey template.
   */
  @OneToMany(mappedBy = "template", cascade = CascadeType.ALL, fetch = FetchType.EAGER,
      orphanRemoval = true)
  @OrderBy("NAME ASC")
  private Set<SurveyTemplateGroupRatingItem> groupRatingItems;

  /**
   * Constructs a new <code>SurveyTemplate</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyTemplate() {}

  /**
   * Constructs a new <code>SurveyTemplate</code>.
   *
   * @param id          the Universally Unique Identifier (UUID) used to uniquely identify the
   *                    survey template
   * @param name        the name of the survey template
   * @param description the description for the survey template
   */
  public SurveyTemplate(UUID id, String name, String description)
  {
    this.id = id;
    this.name = name;
    this.description = description;
    this.groups = new LinkedHashSet<>();
    this.groupRatingItems = new LinkedHashSet<>();
  }

  /**
   * Add the survey template group to the survey template.
   *
   * @param group the survey template group
   */
  public void addGroup(SurveyTemplateGroup group)
  {
    group.setTemplate(this);

    groups.add(group);
  }

  /**
   * Add the survey template group rating item to the survey template.
   *
   * @param groupRatingItem the survey template group rating item
   */
  public void addGroupRatingItem(SurveyTemplateGroupRatingItem groupRatingItem)
  {
    groupRatingItem.setTemplate(this);

    groupRatingItems.add(groupRatingItem);
  }

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

    SurveyTemplate other = (SurveyTemplate) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the description for the survey template.
   *
   * @return the description for the survey template
   */
  public String getDescription()
  {
    return description;
  }

  /**
   * Retrieve the survey template group.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template group
   *
   * @return the survey template group or <code>null</code> if the survey template group could not
   *         be found
   */
  public SurveyTemplateGroup getGroup(UUID id)
  {
    for (SurveyTemplateGroup group : groups)
    {
      if (group.getId().equals(id))
      {
        return group;
      }
    }

    return null;
  }

  /**
   * Retrieve the survey template group rating item.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template group rating item
   *
   * @return the survey template group rating item or <code>null</code> if the survey template
   *         group rating item could not be found
   */
  public SurveyTemplateGroupRatingItem getGroupRatingItem(UUID id)
  {
    for (SurveyTemplateGroupRatingItem groupRatingItem : groupRatingItems)
    {
      if (groupRatingItem.getId().equals(id))
      {
        return groupRatingItem;
      }
    }

    return null;
  }

  /**
   * Returns the group rating items that are associated with a survey template.
   *
   * @return the group rating items that are associated with a survey template
   */
  public Set<SurveyTemplateGroupRatingItem> getGroupRatingItems()
  {
    return groupRatingItems;
  }

  /**
   * Returns the groups of entities that are associated with a survey template.
   *
   * @return the groups of entities that are associated with a survey template
   */
  public Set<SurveyTemplateGroup> getGroups()
  {
    return groups;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey template.
   *
   * @return the name of the survey template
   */
  public String getName()
  {
    return name;
  }

  /**
   * Remove the survey template group from the survey template.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template group
   */
  public void removeGroup(UUID id)
  {
    for (SurveyTemplateGroup group : groups)
    {
      if (group.getId().equals(id))
      {
        groups.remove(group);

        Predicate<SurveyTemplateGroupRatingItem> groupRatingItemPredicate = p-> p.getGroup() == group;

        groupRatingItems.removeIf(groupRatingItemPredicate);

        return;
      }
    }
  }

  /**
   * Set the description for the survey template.
   *
   * @param description the description for the survey template
   */
  public void setDescription(String description)
  {
    this.description = description;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey template.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template
   */
  public void setId(UUID id)
  {
    this.id = id;
  }

  /**
   * Set the name of the survey template.
   *
   * @param name the name of the survey template
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey template.
   *
   * @return the String representation of the survey template
   */
  @Override
  public String toString()
  {
    int count;

    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyTemplate {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("description=\"").append(getDescription()).append("\", ");

    buffer.append("groups={");

    count = 0;

    for (SurveyTemplateGroup group : groups)
    {
      if (count > 0)
      {
        buffer.append(", ");
      }

      buffer.append(group);

      count++;
    }

    buffer.append("}, ");

    buffer.append("groupRatingItems={");

    count = 0;

    for (SurveyTemplateGroupRatingItem groupRatingItem : groupRatingItems)
    {
      if (count > 0)
      {
        buffer.append(", ");
      }

      buffer.append(groupRatingItem);

      count++;
    }

    buffer.append("}");

    buffer.append("}");

    return buffer.toString();
  }
}
