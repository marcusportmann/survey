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
  @OneToMany(mappedBy = "template", cascade = CascadeType.ALL, orphanRemoval = true,
      fetch = FetchType.EAGER)
  private List<SurveyTemplateGroup> groups;

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
    this.groups = new ArrayList<>();
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
   * Returns the groups of entities that are associated with a survey template.
   *
   * @return the groups of entities that are associated with a survey template
   */
  public List<SurveyTemplateGroup> getGroups()
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
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyTemplate {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("description=\"").append(getDescription()).append("\", ");

    buffer.append("groups={");

    for (int i = 0; i < groups.size(); i++)
    {
      if (i > 0)
      {
        buffer.append(", ");
      }

      buffer.append(groups.get(i));
    }

    buffer.append("}");

    buffer.append("}");

    return buffer.toString();
  }
}
