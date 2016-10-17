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
import java.util.UUID;

/**
 * The <code>SurveySectionDefinition</code> class implements the Survey Section Definition entity,
 * which represents a version of a definition for a survey section.
 *
 * @author Marcus Portmann
 */
@Entity
@IdClass(VersionedId.class)
@Table(schema = "SURVEY", name = "SURVEY_SECTION_DEFINITIONS")
public class SurveySectionDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used, along with the version of the survey section
   * definition, to uniquely identify the survey section definition.
   */
  @Id
  private UUID id;

  /**
   * The version of the survey section definition
   */
  @Id
  private int version;

  /**
   * The name of the survey section definition.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The description for the survey section definition.
   */
  @Column(name = "DESCRIPTION", nullable = false)
  private String description;

  /**
   * The index used to define the order of the survey section definitions for a survey definition.
   */
  @Column(name = "INDEX", nullable = false)
  private int index;

  /**
   * The survey definition this survey section definition is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumns({ @JoinColumn(name = "SURVEY_DEFINITION_ID", referencedColumnName = "ID") ,
      @JoinColumn(name = "SURVEY_DEFINITION_VERSION", referencedColumnName = "VERSION") })
  private SurveyDefinition surveyDefinition;

  /**
   * Constructs a new <code>SurveySectionDefinition</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveySectionDefinition() {}

  /**
   * Constructs a new <code>SurveySectionDefinition</code>.
   *
   * @param id           the Universally Unique Identifier (UUID) used, along with the version of
   *                     the survey section definition, to uniquely identify the survey section
   *                     definition
   * @param version      the version of the survey section definition
   * @param index        the index used to define the order of the survey section definitions for a
   *                     survey definition
   * @param name         the name of the survey section definition
   * @param description  the description for the survey section definition
   */
  public SurveySectionDefinition(UUID id, int version, int index, String name, String description)
  {
    this.id = id;
    this.version = version;
    this.index = index;
    this.name = name;
    this.description = description;
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

    SurveySectionDefinition other = (SurveySectionDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the description for the survey section definition.
   *
   * @return the description for the survey section definition
   */
  public String getDescription()
  {
    return description;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used, along with the version of the survey
   * section definition, to uniquely identify the survey section definition.
   *
   * @return the Universally Unique Identifier (UUID) used, along with the version of the survey
   *         section definition, to uniquely identify the survey section definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the index used to define the order of the survey section definitions for a survey
   * definition.
   *
   * @return the index used to define the order of the survey section definitions for a survey
   *         definition
   */
  public int getIndex()
  {
    return index;
  }

  /**
   * Returns the name of the survey section definition.
   *
   * @return the name of the survey section definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the version of the survey section definition.
   *
   * @return the version of the survey section definition
   */
  public int getVersion()
  {
    return version;
  }

  /**
   * Set the description for the survey section definition.
   *
   * @param description the description for the survey section definition
   */
  public void setDescription(String description)
  {
    this.description = description;
  }

  /**
   * Set the index used to define the order of the survey section definitions for a survey
   * definition.
   *
   * @param index the index used to define the order of the survey section definitions for a survey
   *              definition
   */
  public void setIndex(int index)
  {
    this.index = index;
  }

  /**
   * Set the name of the survey section definition.
   *
   * @param name the name of the survey section definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey section definition.
   *
   * @return the String representation of the survey section definition
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveySectionDefinition {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("version=\"").append(getVersion()).append("\", ");
    buffer.append("index=\"").append(getIndex()).append("\"");
    buffer.append("}");

    return buffer.toString();
  }

  /**
   * Increment the version of the survey section definition.
   */
  void incrementVersion()
  {
    version++;
  }

  /**
   * Set the survey definition this survey section definition is associated with.
   *
   * @param surveyDefinition the survey definition this survey section definition is associated with
   */
  void setSurveyDefinition(SurveyDefinition surveyDefinition)
  {
    this.surveyDefinition = surveyDefinition;
  }
}
