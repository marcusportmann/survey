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
 * The <code>SurveyGroupMemberDefinition</code> class implements the Survey Group Member Definition
 * entity, which represents represents the definition of an entity who is a member of a survey
 * group definition, e.g. a member of a team, that is associated with a survey definition
 *
 * @author Marcus Portmann
 */
@Entity
@IdClass(VersionedId.class)
@Table(schema = "SURVEY", name = "SURVEY_GROUP_MEMBER_DEFINITIONS")
public class SurveyGroupMemberDefinition
{
  /**
   * The Universally Unique Identifier (UUID) used, along with the version of the survey group
   * member definition, to uniquely identify the survey group member definition.
   */
  @Id
  private UUID id;

  /**
   * The version of the survey group member definition.
   */
  @Id
  private int version;

  /**
   * The name of the survey group member definition.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The survey group definition this survey group member definition is associated with.
   */
  @ManyToOne
  @JoinColumns({ @JoinColumn(name = "SURVEY_GROUP_DEFINITION_ID", referencedColumnName = "ID") ,
      @JoinColumn(name = "SURVEY_GROUP_DEFINITION_VERSION", referencedColumnName = "VERSION") })
  private SurveyGroupDefinition surveyGroupDefinition;

  /**
   * Constructs a new <code>SurveyGroupMemberDefinition</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyGroupMemberDefinition() {}

  /**
   * Constructs a new <code>SurveyGroupMemberDefinition</code>.
   *
   * @param id      the Universally Unique Identifier (UUID) used, along with the version of the
   *                survey group member definition, to uniquely identify the survey group member
   *                definition
   * @param version the version of the survey group member definition
   * @param name    the name of the survey group member definition
   */
  public SurveyGroupMemberDefinition(UUID id, int version, String name)
  {
    this.id = id;
    this.version = version;
    this.name = name;
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

    SurveyGroupMemberDefinition other = (SurveyGroupMemberDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used, along with the version of the survey
   * group member definition, to uniquely identify the survey group member definition.
   *
   * @return the Universally Unique Identifier (UUID) used, along with the version of the survey
   *         group member definition, to uniquely identify the survey group member definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey group member definition.
   *
   * @return the name of the survey group member definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the version of the survey group member definition.
   *
   * @return the version of the survey group member definition
   */
  public int getVersion()
  {
    return version;
  }

  /**
   * Set the name of the survey group member definition.
   *
   * @param name the name of the survey group member definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey group member definition.
   *
   * @return the String representation of the survey group member definition
   */
  @Override
  public String toString()
  {
    String buffer = "SurveyGroupMemberDefinition {" + "id=\"" + getId() + "\", " + "version=\""
        + getVersion() + "\", " + "name=\"" + getName() + "\"" + "}";

    return buffer;
  }

  /**
   * Set the survey group definition this survey group member definition is associated with.
   *
   * @param surveyGroupDefinition the survey group definition this survey group member definition is
   *                              associated with
   */
  protected void setGroup(SurveyGroupDefinition surveyGroupDefinition)
  {
    this.surveyGroupDefinition = surveyGroupDefinition;
  }
}
