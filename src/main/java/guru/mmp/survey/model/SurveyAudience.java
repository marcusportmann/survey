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
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * The <code>SurveyAudience</code> class implements the Survey Audience entity, which represents a
 * survey audience i.e. a group of external persons who will complete a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_AUDIENCES")
public class SurveyAudience
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey
   * audience is associated with.
   */
  @Column(name = "ORGANISATION_ID", nullable = false)
  private UUID organisationId;

  /**
   * The name of the survey audience.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The survey audience members that are associated with the survey audience.
   */
  @OneToMany(mappedBy = "audience", cascade = CascadeType.ALL, fetch = FetchType.EAGER,
      orphanRemoval = true)
  @OrderBy("firstName ASC")
  private List<SurveyAudienceMember> members;

  /**
   * Constructs a new <code>SurveyAudience</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyAudience() {}

  /**
   * Constructs a new <code>SurveyAudience</code>.
   *
   * @param id             the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       survey audience
   * @param organisationId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       organisation the survey audience is associated with
   * @param name           the name of the survey audience
   */
  public SurveyAudience(UUID id, UUID organisationId, String name)
  {
    this.id = id;
    this.organisationId = organisationId;
    this.name = name;
    this.members = new ArrayList<>();
  }

  /**
   * Add the survey audience member to the survey audience.
   *
   * @param member the survey audience member
   */
  public void addMember(SurveyAudienceMember member)
  {
    member.setAudience(this);

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

    SurveyAudience other = (SurveyAudience) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey audience.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey audience
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Retrieve the survey audience member.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience member
   *
   * @return the survey audience member or <code>null</code> if the survey audience member could
   *         not be found
   */
  public SurveyAudienceMember getMember(UUID id)
  {
    for (SurveyAudienceMember member : members)
    {
      if (member.getId().equals(id))
      {
        return member;
      }
    }

    return null;
  }

  /**
   * Returns the survey audience members that are associated with the survey audience.
   *
   * @return the survey audience members that are associated with the survey audience
   */
  public List<SurveyAudienceMember> getMembers()
  {
    return members;
  }

  /**
   * Returns the name of the survey audience.
   *
   * @return the name of the survey audience
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the organisation the
   * survey audience is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the organisation the
   *         survey audience is associated with
   */
  public UUID getOrganisationId()
  {
    return organisationId;
  }

  /**
   * Remove the survey audience member from the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience member
   */
  public void removeMember(UUID id)
  {
    for (SurveyAudienceMember member : members)
    {
      if (member.getId().equals(id))
      {
        members.remove(member);

        return;
      }
    }
  }

  /**
   * Set the name of the survey audience.
   *
   * @param name the name of the survey audience
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey audience.
   *
   * @return the String representation of the survey audience
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyAudience {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\"");
    buffer.append("}");

    return buffer.toString();
  }
}
