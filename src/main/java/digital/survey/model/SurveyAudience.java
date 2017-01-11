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

import javax.enterprise.inject.Vetoed;
import javax.persistence.*;
import java.io.Serializable;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyAudience</code> class implements the Survey Audience entity, which represents a
 * survey audience i.e. a group of external persons who will complete a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_AUDIENCES")
@Vetoed
public class SurveyAudience
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The description for the survey audience.
   */
  @Column(name = "DESCRIPTION", nullable = false)
  private String description;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The name of the survey audience.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The organisation this survey definition is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "ORGANISATION_ID", referencedColumnName = "ID")
  protected Organisation organisation;

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
   * @param id           the Universally Unique Identifier (UUID) used to uniquely identify the
   *                     survey audience
   * @param organisation the organisation the survey audience is associated with
   * @param name         the name of the survey audience
   * @param description  the description for the survey audience
   */
  public SurveyAudience(UUID id, Organisation organisation, String name, String description)
  {
    this.id = id;
    this.organisation = organisation;
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

    SurveyAudience other = (SurveyAudience) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the description for the survey audience.
   *
   * @return the description for the survey audience
   */
  public String getDescription()
  {
    return description;
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
   * Returns the name of the survey audience.
   *
   * @return the name of the survey audience
   */
  public String getName()
  {
    return name;
  }

  /**
   * Set the description for the survey audience.
   *
   * @param description the description for the survey audience
   */
  public void setDescription(String description)
  {
    this.description = description;
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
    String buffer = "SurveyAudience {" + "id=\"" + getId() + "\", " + "name=\"" + getName()
        + "\", " + "description=\"" + getDescription() + "\"" + "}";

    return buffer;
  }
}
