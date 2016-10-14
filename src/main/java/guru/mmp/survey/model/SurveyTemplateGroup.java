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
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * The <code>SurveyTemplateGroup</code> class implements the Survey Template Group entity, which
 * represents a group of entities, e.g. a team, that are associated with a survey template.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_TEMPLATE_GROUPS")
public class SurveyTemplateGroup
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey template group.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The name of the survey template group.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The description for the survey template group.
   */
  @Column(name = "DESCRIPTION", nullable = false)
  private String description;

  /**
   * The survey template this survey template group is associated with.
   */
  @ManyToOne
  @JoinColumn(name = "SURVEY_TEMPLATE_ID")
  private SurveyTemplate template;

  /**
   * The survey template group members associated with the survey template group.
   */
  @OneToMany(mappedBy = "group", cascade = CascadeType.ALL, fetch = FetchType.EAGER,
      orphanRemoval = true)
  @OrderBy("NAME ASC")
  private List<SurveyTemplateGroupMember> members;

///**
// * The group rating items that are associated with a survey template group.
// */
//@OneToMany(mappedBy = "group", cascade = CascadeType.ALL, fetch = FetchType.EAGER,
//  orphanRemoval = true)
//@OrderBy("NAME ASC")
//private Set<SurveyTemplateGroupRatingItem> groupRatingItems;

  /**
   * Constructs a new <code>SurveyTemplateGroup</code>.
   */
  SurveyTemplateGroup() {}

  /**
   * Constructs a new <code>SurveyTemplateGroup</code>.
   *
   * @param id          the Universally Unique Identifier (UUID) used to uniquely identify the
   *                    survey template group
   * @param name        the name of the survey template group
   * @param description the description for the survey template group
   */
  public SurveyTemplateGroup(UUID id, String name, String description)
  {
    this.id = id;
    this.name = name;
    this.description = description;
    this.members = new ArrayList<>();
  }

  /**
   * Add the survey template group member to the survey template group.
   *
   * @param member the survey template group member
   */
  public void addMember(SurveyTemplateGroupMember member)
  {
    member.setGroup(this);

    members.add(member);
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

    SurveyTemplateGroup other = (SurveyTemplateGroup) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the description for the survey template group.
   *
   * @return the description for the survey template group
   */
  public String getDescription()
  {
    return description;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   *         group
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Retrieve the survey template group member.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template group member
   *
   * @return the survey template group member or <code>null</code> if the survey template group
   *         member could not be found
   */
  public SurveyTemplateGroupMember getMember(UUID id)
  {
    for (SurveyTemplateGroupMember member : members)
    {
      if (member.getId().equals(id))
      {
        return member;
      }
    }

    return null;
  }

  /**
   * Returns the survey template group members associated with the survey template group.
   *
   * @return the survey template group members associated with the survey template group
   */
  public List<SurveyTemplateGroupMember> getMembers()
  {
    return members;
  }

  /**
   * Returns the name of the survey template group.
   *
   * @return the name of the survey template group
   */
  public String getName()
  {
    return name;
  }

  /**
   * Remove the survey template group member from the survey template group.
   *
   * @param id the Universally Unique Identifier (UUID) used  to uniquely identify the survey
   *           template group member
   */
  public void removeMember(UUID id)
  {
    for (SurveyTemplateGroupMember member : members)
    {
      if (member.getId().equals(id))
      {
        members.remove(member);

        return;
      }
    }
  }

  /**
   * Set the description for the survey template group.
   *
   * @param description the description for the survey template group
   */
  public void setDescription(String description)
  {
    this.description = description;
  }

  /**
   * Set the name of the survey template group
   *
   * @param name the name of the survey template group
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Set the survey template this survey template group is associated with.
   *
   * @param template the survey template this survey template group is associated with
   */
  public void setTemplate(SurveyTemplate template)
  {
    this.template = template;
  }

  /**
   * Returns the String representation of the survey template group.
   *
   * @return the String representation of the survey template group
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyTemplateGroup {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("description=\"").append(getDescription()).append("\", ");

    buffer.append("members={");

    for (int i = 0; i < members.size(); i++)
    {
      if (i > 0)
      {
        buffer.append(", ");
      }

      buffer.append(members.get(i));
    }

    buffer.append("}");

    buffer.append("}");

    return buffer.toString();
  }
}
