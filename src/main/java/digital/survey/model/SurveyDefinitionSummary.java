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

import guru.mmp.application.security.Organisation;

import javax.persistence.*;
import java.io.Serializable;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyDefinitionSummary</code> class implements the Survey Definition Summary entity,
 * which represents a summary for a version of a definition for a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@IdClass(VersionedId.class)
@Table(schema = "SURVEY", name = "SURVEY_DEFINITIONS")
public class SurveyDefinitionSummary
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to, along with the version of the survey
   * definition, uniquely identify the survey definition.
   */
  @Id
  private UUID id;

  /**
   * The version of the survey definition
   */
  @Id
  private int version;

  /**
   * The name of the survey definition.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * Constructs a new <code>SurveyDefinitionSummary</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyDefinitionSummary() {}

  /**
   * Constructs a new <code>SurveyDefinitionSummary</code>.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   * @param name    the name of the survey definition
   */
  @SuppressWarnings("unused")
  public SurveyDefinitionSummary(UUID id, int version, String name)
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

    SurveyDefinitionSummary other = (SurveyDefinitionSummary) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to, along with the version of the survey
   * definition, uniquely identify the survey definition.
   *
   * @return the Universally Unique Identifier (UUID) used to, along with the version of the survey
   *         definition, uniquely identify the survey definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey definition.
   *
   * @return the name of the survey definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the version of the survey definition.
   *
   * @return the version of the survey definition
   */
  public int getVersion()
  {
    return version;
  }

  /**
   * Returns the String representation of the survey definition.
   *
   * @return the String representation of the survey definition
   */
  @Override
  public String toString()
  {
    int count;

    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyDefinitionSummary {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("version=\"").append(getVersion()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\"");
    buffer.append("}");

    return buffer.toString();
  }

  /**
   * Increment the version of the survey definition.
   */
  void incrementVersion()
  {
    version++;
  }
}
